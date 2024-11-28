using System.Collections.Concurrent;
using HtmlAgilityPack;
using Spectre.Console;

namespace LinkExtractor;

/// <summary>
/// Service for extracting links from a collection of URLs.
/// </summary>
public sealed class LinkExtractorService
{
    /// <summary>
    /// 
    /// </summary>
    private readonly HttpClient _httpClient;

    public LinkExtractorService(HttpClient httpClient)
    {
        _httpClient = httpClient ?? throw new ArgumentNullException(nameof(httpClient));
    }

    /// <summary>
    /// Fetches links from a single URL.
    /// </summary>
    /// <param name="url">The URL to fetch links from.</param>
    /// <returns>A list of extracted links.</returns>
#pragma warning disable CS0628 // New protected member declared in sealed type
    protected internal async Task<List<string>> GetLinksFromUrl(string url)
#pragma warning restore CS0628 // New protected member declared in sealed type
    {
        ArgumentNullException.ThrowIfNull(url);

        var response = await _httpClient.GetStringAsync(url);
        var document = new HtmlDocument();
        document.LoadHtml(response);

        var links = document.DocumentNode.SelectNodes("//a[@href]")
            ?.Select(node => node.GetAttributeValue("href", ""))
            .Where(href => !string.IsNullOrEmpty(href))
            .Select(link =>
            {
                return Uri.TryCreate(new Uri(url), link, out var absoluteUri)
                    ? absoluteUri.ToString()
                    : link;
            })
            .ToList();

        return links ?? new List<string>();
    }

    /// <summary>
    /// Extracts links from a collection of URLs and groups them by base domain.
    /// </summary>
    /// <param name="urls">The collection of URLs to process.</param>
    /// <param name="context">The progress context for tracking tasks.</param>
    /// <returns>A dictionary of base domains to their extracted links.</returns>
    public async Task<Dictionary<string, List<string>>> ExtractLinksAsync(IEnumerable<string> urls, ProgressContext context)
    {
        ArgumentNullException.ThrowIfNull(urls);
        ArgumentNullException.ThrowIfNull(context);

        var result = new ConcurrentDictionary<string, List<string>>();
        var tasks = urls.Select(async url =>
        {
            var task = context.AddTask($"Extracting Links: \"{url}\"");
            try
            {
                var links = await GetLinksFromUrl(url);
                if (links.Any())
                {
                    var baseUrl = new Uri(url).GetLeftPart(UriPartial.Authority);
                    result.AddOrUpdate(baseUrl, links, (key, existing) => existing.Concat(links).ToList());
                }
            }
            catch (Exception ex)
            {
                AnsiConsole.WriteLine($"Error fetching links from {url}: {ex.Message}");
            }
            finally
            {
                task.Increment(100); // Update progress
            }
        });

        await Task.WhenAll(tasks);
        return result.ToDictionary(kvp => kvp.Key, kvp => kvp.Value);
    }
}
