using AI_Derma.Core.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Core.Interfaces
{
    public interface IDiagnosticResultRepository : IGenericRepository<DiagnosticResult>
    {
        Task<IEnumerable<DiagnosticResult>> GetByUserIdAsync(string userId);
    }
}
