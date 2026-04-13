using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Core.DTOs
{
    public class ImageDiagnosisRequestDto
    {
        public IFormFile Image { get; set; }
    }
}
