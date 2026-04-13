using AI_Derma.Core.Interfaces;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Infrastructure.Repos
{
    public class FastAPIService : IFastAPIService
    {
        public async Task<dynamic> GetNextStepAsync(List<string> facts)
        {
            // TODO: call FastAPI
            return new { type = "", code = "" };
        }

        public async Task<(string disease, float confidence)> PredictImageAsync(IFormFile file)
        {
            // TODO: call CNN
            return ("", 0.0f);
        }
    }
}
