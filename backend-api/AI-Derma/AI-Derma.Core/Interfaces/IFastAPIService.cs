using AI_Derma.Core.DTOs;
using Microsoft.AspNetCore.Http;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace AI_Derma.Core.Interfaces
{
    public interface IFastAPIService
    {
        Task<FastApiNextStepResponse> GetNextStepAsync(List<string> facts);
        Task<(string disease, float confidence)> PredictImageAsync(IFormFile file);
    }
}
