using System;
using System.Collections.Generic;

namespace PowerBranch.Models
{
    public partial class Points
    {
        public Points()
        {
            Mesures = new HashSet<Mesures>();
        }

        public string Name { get; set; }
        public double? X { get; set; }
        public double? Y { get; set; }
        public double? Z { get; set; }
        public DateTime? CreationDate { get; set; }

        public virtual ICollection<Mesures> Mesures { get; set; }
    }
}
