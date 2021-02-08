using System;
using System.Collections.Generic;

namespace PowerBranch.Models
{
    public partial class Mesures
    {
        public int Id { get; set; }
        public string Point { get; set; }
        public DateTime? Date { get; set; }
        public double? Mesure { get; set; }
        public bool IsPredicted { get; set; }

        public virtual Points PointNavigation { get; set; }

        private static int id_increment = 200000;

        public Mesures(string point, DateTime? date, double? mesure, bool isPredicted)
        {
            Point = point;
            Date = date;
            Mesure = mesure;
            IsPredicted = isPredicted;

            Id = id_increment++;
        }
    }
}
