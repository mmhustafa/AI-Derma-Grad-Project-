using AI_Derma.Core.Interfaces;
using AI_Derma.Core.Models;
using AI_Derma.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Infrastructure.Repos
{
    public class DiagnosticResultRepository : GenericRepository<DiagnosticResult>, IDiagnosticResultRepository
    {
        public DiagnosticResultRepository(DermaDbContext context) : base(context) { }

        public async Task<IEnumerable<DiagnosticResult>> GetByUserIdAsync(string userId)
        {
            return await _context.DiagnosticResults
                .Where(d => d.UserId == userId)
                .Include(d => d.Disease)
                .ToListAsync();
        }
      
        public async Task<DiagnosticResult> GetbyDiagnosticResultIdAsync(int id)
        {
            return await _context.DiagnosticResults
                .Include(d => d.Disease) 
                .FirstOrDefaultAsync(d => d.Id == id);
        }
    }
}
