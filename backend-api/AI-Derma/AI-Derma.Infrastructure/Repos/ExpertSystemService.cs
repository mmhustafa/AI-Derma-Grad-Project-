using AI_Derma.Core.DTOs;
using AI_Derma.Core.Interfaces;
using Microsoft.AspNetCore.Http;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text.Json;
using System.Threading.Tasks;

namespace AI_Derma.Infrastructure.Repos
{
    /// <summary>
    /// Calls the Expert System FastAPI service (port 8002) — /kb/next-step
    /// </summary>
    public class ExpertSystemService : IFastAPIService
    {
        private readonly HttpClient _httpClient;

        public ExpertSystemService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<FastApiNextStepResponse> GetNextStepAsync(List<string> facts)
        {
            var response = await _httpClient.PostAsJsonAsync("/kb/next-step", new { facts });

            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            var result = await response.Content.ReadFromJsonAsync<FastApiNextStepResponse>(options);
            return result ?? new FastApiNextStepResponse();
        }

        Task<ImageDiagnosisResponseDto> IFastAPIService.PredictImageAsync(IFormFile file)
        {
            throw new NotImplementedException();
        }
    }
}
