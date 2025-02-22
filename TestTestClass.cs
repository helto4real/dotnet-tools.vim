using dotnet_tools;
using Xunit;

    /// <summary>
    /// Contains tests for the TextClass.
    /// </summary>
    public class TextClassTests
    {
        /// <summary>
        /// Tests that GetText returns the expected greeting.
        /// </summary>
        [Fact]
        public void GetText_ShouldReturnExpectedValue()
        {
            // Define the expected result.
            // expected is a string representing the default greeting.
            string expected = "Hello, World!";

            // Act: Retrieve the actual text.
            string actual = TestClass.GetText();

            // Assert: Verify that the actual result matches the expected value.
            Assert.Equal(expected, actual);
        }
    }

