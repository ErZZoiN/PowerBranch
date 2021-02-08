using System;
using System.Collections.Generic;
using System.Text;

namespace PowerBranch
{
    public class ResultContainer
    {
        public OutputContainer Results { get; set; }

        public ResultContainer(OutputContainer results)
        {
            Results = results;
        }
    }
}
