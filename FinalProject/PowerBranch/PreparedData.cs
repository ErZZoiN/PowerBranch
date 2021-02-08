using System;
using System.Collections.Generic;
using System.Text;

namespace PowerBranch
{
    public class PreparedData
    {
        public string points { get; set; }
        public DateTime date { get; set; }
        public double value { get; set; }
        public double x { get; set; }
        public double y { get; set; }
        public double valuePrec1 { get; set; }
        public double valuePrec2 { get; set; }
        public double neighbours1value { get; set; }
        public double neighbours1valuePrec1 { get; set; }
        public double neighbours1valuePrec2 { get; set; }
        public double neighbours2value { get; set; }
        public double neighbours2valuePrec1 { get; set; }
        public double neighbours2valuePrec2 { get; set; }
        public double neighbours3value { get; set; }
        public double neighbours3valuePrec1 { get; set; }
        public double neighbours3valuePrec2 { get; set; }

        public PreparedData(string points, DateTime date,
            double value, double x, double y, double valuePrec1, double valuePrec2,
            double neighbours1value, double neighbours1valuePrec1, double neighbours1valuePrec2,
            double neighbours2value, double neighbours2valuePrec1, double neighbours2valuePrec2,
            double neighbours3value, double neighbours3valuePrec1, double neighbours3valuePrec2)
        {
            this.points = points;
            this.date = date;
            this.value = value;
            this.x = x;
            this.y = y;
            this.valuePrec1 = valuePrec1;
            this.valuePrec2 = valuePrec2;
            this.neighbours1value = neighbours1value;
            this.neighbours1valuePrec1 = neighbours1valuePrec1;
            this.neighbours1valuePrec2 = neighbours1valuePrec2;
            this.neighbours2value = neighbours2value;
            this.neighbours2valuePrec1 = neighbours2valuePrec1;
            this.neighbours2valuePrec2 = neighbours2valuePrec2;
            this.neighbours3value = neighbours3value;
            this.neighbours3valuePrec1 = neighbours3valuePrec1;
            this.neighbours3valuePrec2 = neighbours3valuePrec2;
        }

        public PreparedData() { }

        public override string ToString()
        {
            return $"Points : {points} // value : {value} // date : {date} // valuePrec1 : {valuePrec1}" +
                $" // valuePrec2 : {valuePrec2} // neighboursPrec1 : {neighbours1valuePrec1} // neighboursPrec2 : {neighbours1valuePrec2}";
        }
    }
}
