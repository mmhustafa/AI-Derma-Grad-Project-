using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace AI_Derma.Core.DTOs
{
    public class ImageDiagnosisResponseDto
    {
        public string Disease { get; set; }
        public float Confidence { get; set; }

        [JsonPropertyName("top_3")]
        public List<TopPredictionDto> Top3 { get; set; }
    }

    public class TopPredictionDto
    {
        public string Disease { get; set; }
        public float Confidence { get; set; }
    }
}