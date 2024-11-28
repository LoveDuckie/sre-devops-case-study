using System.ComponentModel;
using System.Text.Json;
using Spectre.Console;
using Spectre.Console.Cli;

namespace LinkExtractor;

/// <summary>
///    The command for extracting links
/// </summary>
public sealed class ExtractLinksCommand : AsyncCommand<ExtractLinksCommand.Settings>
{
    private readonly LinkExtractorService _linkExtractorService;

    public ExtractLinksCommand(LinkExtractorService linkExtractorService)
    {
        _linkExtractorService = linkExtractorService;
    }

    /// <summary>
    ///     
    /// </summary>
    public class Settings : CommandSettings
    {
        /// <summary>
        ///     The URLs.
        /// </summary>
        [CommandOption("-u|--url <URL>")]
        [Description("The URLs to process.")]
        public string[]? Urls { get; set; }

        /// <summary>
        ///     The output.
        /// </summary>
        [CommandOption("-o|--output <OUTPUT>")]
        [Description("The output format: 'stdout' or 'json'.")]
        public string? Output { get; set; }

        /// <summary>
        ///     
        /// </summary>
        /// <returns>Returns the result from validation.</returns>
        public override ValidationResult Validate()
        {
            if (Urls is null)
            {
                return ValidationResult.Error("Failed: The URLs are not specified.");
            }

            if (Urls != null && Urls.Length == 0)
            {
                return ValidationResult.Error("No URLs provided. Use the '-u' option to specify at least one URL.");
            }

            if (Urls != null)
                foreach (var url in Urls)
                {
                    if (!Uri.IsWellFormedUriString(url, UriKind.Absolute))
                    {
                        return ValidationResult.Error($"Invalid URL: {url}. Please provide a valid URL.");
                    }
                }

            // Validate the output format
            if (string.IsNullOrEmpty(Output) || (!Output.Equals("stdout", StringComparison.OrdinalIgnoreCase) &&
                                                 !Output.Equals("json", StringComparison.OrdinalIgnoreCase)))
            {
                return ValidationResult.Error("Invalid output format. Use 'stdout' or 'json' for the '-o' option.");
            }

            return ValidationResult.Success();
        }
    }


    /// <summary>
    ///     The command to execute.
    /// </summary>
    /// <param name="context"></param>
    /// <param name="settings"></param>
    /// <returns></returns>
    /// <exception cref="ArgumentNullException"></exception>
    public override async Task<int> ExecuteAsync(CommandContext context, Settings settings)
    {
        if (context == null) throw new ArgumentNullException(nameof(context));
        if (settings == null) throw new ArgumentNullException(nameof(settings));

        if (settings.Urls != null && settings.Urls.Length == 0)
        {
            AnsiConsole.WriteLine("Error: No URLs provided.");
            return 1;
        }

        if (string.IsNullOrEmpty(settings.Output) ||
            (!settings.Output.Equals("stdout") && !settings.Output.Equals("json")))
        {
            AnsiConsole.WriteLine("Error: Invalid output option. Use 'stdout' or 'json'.");
            return 1;
        }

        if (settings.Urls == null) return 0;
        Dictionary<string, List<string>>? links = null;
        // Synchronous
        await AnsiConsole.Progress()
            .StartAsync(async (ctx) => { links = await _linkExtractorService.ExtractLinksAsync(settings.Urls, ctx); });

        if (links == null || links.Count == 0)
        {
            return 0;
        }

        switch (settings.Output)
        {
            case "stdout":
            {
                foreach (var domain in links.Keys)
                {
                    foreach (var link in links[domain])
                    {
                        AnsiConsole.WriteLine(link);
                    }
                }

                break;
            }
            case "json":
            {
                var json = JsonSerializer.Serialize(links, new JsonSerializerOptions { WriteIndented = true });
                AnsiConsole.WriteLine(json);
                break;
            }
        }

        return 0;
    }
}