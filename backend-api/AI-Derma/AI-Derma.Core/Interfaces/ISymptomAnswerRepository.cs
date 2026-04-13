using AI_Derma.Core.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Core.Interfaces
{
    public interface ISymptomAnswerRepository : IGenericRepository<SymptomAnswer>
    {
        Task<IEnumerable<SymptomAnswer>> GetByDiagnosticIdAsync(int diagnosticId);
    }
}
