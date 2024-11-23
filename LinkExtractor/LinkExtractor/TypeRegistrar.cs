using Microsoft.Extensions.DependencyInjection;
using Spectre.Console.Cli;

namespace LinkExtractor;

/// <summary>
///     
/// </summary>
public sealed class TypeRegistrar : ITypeRegistrar
{
    /// <summary>
    /// 
    /// </summary>
    private readonly IServiceCollection _services;

    /// <summary>
    /// 
    /// </summary>
    /// <param name="services"></param>
    public TypeRegistrar(IServiceCollection services)
    {
        _services = services;
    }

    /// <summary>
    ///     
    /// </summary>
    /// <param name="service"></param>
    /// <param name="factory"></param>
    /// <exception cref="NotImplementedException"></exception>
    public void RegisterLazy(Type service, Func<object> factory)
    {
        throw new NotImplementedException();
    }

    /// <summary>
    ///     
    /// </summary>
    /// <returns></returns>
    public ITypeResolver Build()
    {
        var serviceProvider = _services.BuildServiceProvider();
        return new TypeResolver(serviceProvider);
    }

    /// <summary>
    ///     
    /// </summary>
    /// <param name="service"></param>
    /// <param name="implementation"></param>
    public void Register(Type service, Type implementation)
    {
        _services.AddTransient(service, implementation);
    }

    /// <summary>
    ///     
    /// </summary>
    /// <param name="service"></param>
    /// <param name="implementation"></param>
    public void RegisterInstance(Type service, object implementation)
    {
        _services.AddSingleton(service, implementation);
    }

    /// <summary>
    ///     
    /// </summary>
    /// <param name="service"></param>
    /// <param name="factory"></param>
    public void Register(Type service, Func<object> factory)
    {
        _services.AddTransient(service, _ => factory());
    }
}

/// <summary>
///     
/// </summary>
public class TypeResolver : ITypeResolver
{
    private readonly IServiceProvider _provider;

    /// <summary>
    ///     
    /// </summary>
    /// <param name="provider"></param>
    public TypeResolver(IServiceProvider provider)
    {
        _provider = provider;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="type"></param>
    /// <returns></returns>
    /// <exception cref="ArgumentNullException"></exception>
    public object? Resolve(Type? type)
    {
        if (type == null) throw new ArgumentNullException(nameof(type));
        return _provider.GetService(type);
    }
}