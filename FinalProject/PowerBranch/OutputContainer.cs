using System;
using System.Collections.Generic;
using System.Text;

namespace PowerBranch
{
    public class OutputContainer
    {
        public List<APIOutput> output1 { get; set; }

        public OutputContainer(List<APIOutput> output1)
        {
            this.output1 = output1;
        }
    }
}
