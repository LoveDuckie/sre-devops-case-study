using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Spectre.Console.Cli;

namespace LinkExtractor;

internal class Program
{
    public static async Task Main(string[] args)
    {
        var host = Host.CreateDefaultBuilder(args)
            .ConfigureServices((context, services) =>
            {
                services.AddHttpClient<LinkExtractorService>();

                var registrar = new TypeRegistrar(services);
                var app = new CommandApp(registrar);

                app.Configure(config => { config.AddCommand<ExtractLinksCommand>("extract"); });

                services.AddSingleton(app);
            })
            .Build();

        var appInstance = host.Services.GetRequiredService<CommandApp>();
        await appInstance.RunAsync(args);
    }
}