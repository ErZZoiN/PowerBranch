using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace PowerBranch
{
    public class APIOutput
    {
        public DateTime date { get; set; }
        public string value { get; set; }
        public double x { get; set; }
        public double y { get; set; }
        public double valuePrec2 { get; set; }
        public double neighbours1valuePrec1 { get; set; }
        public double neighbours1valuePrec2 { get; set; }
        public double neighbours2valuePrec1 { get; set; }
        public double neighbours2valuePrec2 { get; set; }
        public double neighbours3valuePrec1 { get; set; }
        public double neighbours3valuePrec2 { get; set; }

        [JsonProperty(PropertyName = "Scored Labels")]
        public double ScoredLabels { get; set; }

        public APIOutput(DateTime date, string value, double x, double y, double valuePrec2, double neighbours1valuePrec1, double neighbours1valuePrec2,
            double neighbours2valuePrec1, double neighbours2valuePrec2, double neighbours3valuePrec1, double neighbours3valuePrec2, double scoredLabels)
        {
            this.date = date;
            this.value = value;
            this.x = x;
            this.y = y;
            this.valuePrec2 = valuePrec2;
            this.neighbours1valuePrec1 = neighbours1valuePrec1;
            this.neighbours1valuePrec2 = neighbours1valuePrec2;
            this.neighbours2valuePrec1 = neighbours2valuePrec1;
            this.neighbours2valuePrec2 = neighbours2valuePrec2;
            this.neighbours3valuePrec1 = neighbours3valuePrec1;
            this.neighbours3valuePrec2 = neighbours3valuePrec2;
            ScoredLabels = scoredLabels;
        }
    }
}
