using AI_Derma.Core.Interfaces;
using AI_Derma.Core.Models;
using AI_Derma.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Infrastructure.Repos
{
    public class SymptomAnswerRepository : GenericRepository<SymptomAnswer>, ISymptomAnswerRepository
    {
        public SymptomAnswerRepository(DermaDbContext context) : base(context) { }

        public async Task<IEnumerable<SymptomAnswer>> GetByDiagnosticIdAsync(int diagnosticId)
        {
            return await _context.SymptomAnswers
                .Where(s => s.DiagnosticResultId == diagnosticId)
                .ToListAsync();
        }
    }
}
