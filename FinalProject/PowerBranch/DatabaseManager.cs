using PowerBranch.Models;
using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace PowerBranch
{
    public class DatabaseManager
    {
        private PowerBranchContext _context;

        public DatabaseManager(PowerBranchContext context)
        {
            _context = context;
        }

        public DateTime getLastDate()
        {
            return _context.Mesures.Max(m => m.Date).Value;
        }

        public void addPrediction(List<Mesures> mesures)
        {
            foreach (Mesures m in mesures)
            {
                _context.Mesures.Add(m);
            }

            _context.SaveChanges();
        }
    }
}
