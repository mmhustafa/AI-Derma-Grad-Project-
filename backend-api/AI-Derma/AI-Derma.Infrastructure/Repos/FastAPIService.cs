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
    public class FastAPIService : IFastAPIService
    {
        private readonly HttpClient _httpClient;

        public FastAPIService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<FastApiNextStepResponse> GetNextStepAsync(List<string> facts)
        {
            var response = await _httpClient.PostAsJsonAsync("/kb/next-step", new { facts });
            response.EnsureSuccessStatusCode();

            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            };

            var result = await response.Content.ReadFromJsonAsync<FastApiNextStepResponse>(options);
            return result ?? new FastApiNextStepResponse();
        }

        public async Task<(string disease, float confidence)> PredictImageAsync(IFormFile file)
        {
            // TODO: call CNN
            return ("", 0.0f);
        }
    }
}
