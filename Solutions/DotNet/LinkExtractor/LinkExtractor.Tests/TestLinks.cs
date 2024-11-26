using Moq;
using Moq.Protected;
using System.Net;
using Spectre.Console;

namespace LinkExtractor.Tests
{
    [TestFixture]
    public class LinkExtractorServiceTests
    {
        private Mock<HttpMessageHandler> _httpMessageHandlerMock;
        private HttpClient _httpClient;
        private LinkExtractorService _service;

        [SetUp]
        public void SetUp()
        {
            _httpMessageHandlerMock = new Mock<HttpMessageHandler>();
            _httpClient = new HttpClient(_httpMessageHandlerMock.Object);
            _service = new LinkExtractorService(_httpClient);
        }

        [Test]
        public async Task GetLinksFromUrl_ValidUrl_ReturnsLinks()
        {
            // Arrange
            var url = "https://example.com";
            var html = @"
                <html>
                    <body>
                        <a href=""https://example.com/page1"">Page 1</a>
                        <a href=""page2"">Page 2</a>
                        <a href=""/page3"">Page 3</a>
                    </body>
                </html>";

            _httpMessageHandlerMock
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent(html)
                });

            // Act
            var links = await _service.GetLinksFromUrl(url);

            // Assert
            var expectedLinks = new List<string>
            {
                "https://example.com/page1",
                "https://example.com/page2",
                "https://example.com/page3"
            };

            CollectionAssert.AreEquivalent(expectedLinks, links);
        }

        /// <summary>
        /// 
        /// </summary>
        [Test]
        public void GetLinksFromUrl_NullUrl_ThrowsArgumentNullException()
        {
            // Act & Assert
            Assert.ThrowsAsync<ArgumentNullException>(async () => await _service.GetLinksFromUrl(null!));
        }

        /// <summary>
        ///     
        /// </summary>
        [Test]
        public async Task ExtractLinksAsync_MultipleUrls_ReturnsGroupedLinks()
        {
            // Arrange
            var urls = new List<string>
            {
                "https://example.com",
                "https://another.com"
            };

            _httpMessageHandlerMock
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.Is<HttpRequestMessage>(req => req.RequestUri.ToString() == "https://example.com"),
                    ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent(@"
                        <html>
                            <body>
                                <a href=""https://example.com/page1"">Page 1</a>
                                <a href=""/page2"">Page 2</a>
                            </body>
                        </html>")
                });

            _httpMessageHandlerMock
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.Is<HttpRequestMessage>(req => req.RequestUri.ToString() == "https://another.com"),
                    ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent(@"
                        <html>
                            <body>
                                <a href=""https://another.com/page1"">Page 1</a>
                            </body>
                        </html>")
                });

            var contextMock = new Mock<ProgressContext>();

            var result = await _service.ExtractLinksAsync(urls, contextMock.Object);

            Assert.AreEqual(2, result.Count);
            Assert.IsTrue(result.ContainsKey("https://example.com"));
            Assert.IsTrue(result.ContainsKey("https://another.com"));

            CollectionAssert.AreEquivalent(new[] { "https://example.com/page1", "https://example.com/page2" }, result["https://example.com"]);
            CollectionAssert.AreEquivalent(new[] { "https://another.com/page1" }, result["https://another.com"]);
        }

        [Test]
        public void ExtractLinksAsync_NullUrls_ThrowsArgumentNullException()
        {
            var contextMock = new Mock<ProgressContext>();
            Assert.ThrowsAsync<ArgumentNullException>(async () => await _service.ExtractLinksAsync(null!, contextMock.Object));
        }

        [Test]
        public void ExtractLinksAsync_NullContext_ThrowsArgumentNullException()
        {
            var urls = new List<string> { "https://example.com" };
            Assert.ThrowsAsync<ArgumentNullException>(async () => await _service.ExtractLinksAsync(urls, null!));
        }

        [Test]
        public async Task ExtractLinksAsync_FailureToFetch_LogsError()
        {
            var urls = new List<string> { "https://example.com" };

            _httpMessageHandlerMock
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ThrowsAsync(new HttpRequestException("Network error"));

            var contextMock = new Mock<ProgressContext>();

            var result = await _service.ExtractLinksAsync(urls, contextMock.Object);

            Assert.IsEmpty(result);
        }
    }
}
