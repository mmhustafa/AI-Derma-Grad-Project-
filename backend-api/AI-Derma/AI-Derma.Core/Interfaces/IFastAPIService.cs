using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Core.Interfaces
{
    public interface IFastAPIService
    {
        Task<dynamic> GetNextStepAsync(List<string> facts);
        Task<(string disease, float confidence)> PredictImageAsync(IFormFile file);
    }
}
