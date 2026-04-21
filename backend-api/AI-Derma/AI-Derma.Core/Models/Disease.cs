using System.Text.Json.Serialization;

namespace AI_Derma.Core.Models
{
    public class Disease
    {
        public int Id { get; set; }

        public string DiseaseName { get; set; }

        public string Description { get; set; }

        public string SeverityLevel { get; set; }

        public string CareInstructions { get; set; }

        [JsonIgnore]
        public ICollection<DiagnosticResult> DiagnosticResults { get; set; }
    }
}