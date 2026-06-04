using AI_Derma.Core.DTOs;
using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;

namespace AI_Derma.Core.Interfaces
{
    public interface IPredictionService
    {
        Task<ImageDiagnosisResponseDto> PredictImageAsync(IFormFile file);
    }
}
