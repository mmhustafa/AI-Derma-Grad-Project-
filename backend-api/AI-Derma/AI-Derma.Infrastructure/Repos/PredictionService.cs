using AI_Derma.Core.DTOs;
using AI_Derma.Core.Interfaces;
using Microsoft.AspNetCore.Http;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text.Json;
using System.Threading.Tasks;

namespace AI_Derma.Infrastructure.Repos
{
    /// <summary>
    /// Calls the Image Prediction FastAPI service (port 8001) — /predict
    /// </summary>
    public class PredictionService : IPredictionService
    {
        private readonly HttpClient _httpClient;

        public PredictionService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<ImageDiagnosisResponseDto> PredictImageAsync(IFormFile file)
        {
            using var content = new MultipartFormDataContent();
            using var stream = file.OpenReadStream();
            var fileContent = new StreamContent(stream);
            fileContent.Headers.ContentType =
                new System.Net.Http.Headers.MediaTypeHeaderValue(file.ContentType);
            content.Add(fileContent, "file", file.FileName);

            var response = await _httpClient.PostAsync("/predict", content);
            response.EnsureSuccessStatusCode();

            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            var result = await response.Content.ReadFromJsonAsync<ImageDiagnosisResponseDto>(options);
            return result ?? new ImageDiagnosisResponseDto();
        }
    }
}
