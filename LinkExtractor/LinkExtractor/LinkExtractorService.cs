using System.Collections.Concurrent;
using HtmlAgilityPack;
using Spectre.Console;

namespace LinkExtractor;

/// <summary>
/// 
/// </summary>
public sealed class LinkExtractorService
{
    /// <summary>
    ///     The client to be used for scraping URLs
    /// </summary>
    private readonly HttpClient _httpClient;

    /// <summary>
    ///     
    /// </summary>
    /// <param name="httpClient">The http client to use.</param>
    public LinkExtractorService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }


    /// <summary>
    ///     Get links from the URL specified.
    /// </summary>
    /// <param name="url">The URL to get the links from.</param>
    /// <returns>Returns the list of links</returns>
    private async Task<List<string>?> GetLinksFromUrl(string url)
    {
        ArgumentNullException.ThrowIfNull(url);
        var response = await _httpClient.GetStringAsync(url);
        var document = new HtmlDocument();
        document.LoadHtml(response);

        var links = document.DocumentNode.SelectNodes("//a[@href]")
            ?.Select(node => node.GetAttributeValue("href", ""))
            .Where(href => !string.IsNullOrEmpty(href))
            .ToList();

        if (links == null)
            throw new ArgumentNullException(nameof(links));

        links = links.Select(link =>
        {
            if (Uri.TryCreate(link, UriKind.Absolute, out var absoluteUri))
            {
                return absoluteUri.ToString();
            }

            return link.StartsWith("/") ? link : "/" + link;
        }).ToList();

        return links;
    }

    /// <summary>
    ///     
    /// </summary>
    /// <param name="urls"></param>
    /// <param name="context"></param>
    /// <returns>Returns the Dictionary of domain to links found</returns>
    public async Task<Dictionary<string, List<string>>> ExtractLinksAsync(IEnumerable<string> urls, ProgressContext context)
    {
        if (context == null) throw new ArgumentNullException(nameof(context));
        ArgumentNullException.ThrowIfNull(urls);
        var result = new ConcurrentDictionary<string, List<string>>();
        if (result == null) throw new ArgumentNullException(nameof(result));
        var tasks = new List<Task>();
        foreach (var url in urls)
        {
            tasks.Add(Task.Run(async () =>
            {
                context.AddTask($"Extracting Links: \"{url}\"");
                try
                {
                    List<string>? links = await GetLinksFromUrl(url);
                    if (links == null) throw new ArgumentNullException(nameof(links));
                    var baseUrl = new Uri(url).GetLeftPart(UriPartial.Authority) ??
                                  throw new ArgumentNullException(nameof(url));
                    result[baseUrl] = links;
                }
                catch (Exception ex)
                {
                    AnsiConsole.WriteLine($"Error fetching links from {url}: {ex.Message}");
                }
            }));
        }

        await Task.WhenAll(tasks);

        return result.ToDictionary(link => link.Key, link => link.Value);
    }
}