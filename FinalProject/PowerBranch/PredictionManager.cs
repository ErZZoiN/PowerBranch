using System;
using CsvHelper;
using System.IO;
using System.Globalization;
using System.Linq;
using CsvHelper.TypeConversion;
using CsvHelper.Configuration;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading.Tasks;
using PowerBranch.Models;

namespace PowerBranch
{
    public class PredictionManager
    {
        private DatabaseManager DBManager;
        public APICaller caller;

        private string folder = Directory.GetCurrentDirectory() + "\\MachineLearning\\";
        private string pathToR = "C:\\Program Files\\R\\R-3.6.3\\bin\\x64\\";
        private static int MONTHS = 5;
        //private string pathToR = Directory.GetCurrentDirectory() + "\\R-3.6.0\\bin\\x64\\";

        public PredictionManager(DatabaseManager k)
        {
            DBManager = k;
            caller = new APICaller();
        }

        private List<PreparedData> getNextBatch(string folder)
        {
            List<PreparedData> result = new List<PreparedData>();

            using (StreamReader reader = new StreamReader(folder + "\\next_set.csv"))
            using (var csv = new CsvReader(reader, CultureInfo.InvariantCulture))
            {
                csv.Configuration.TypeConverterCache.AddConverter(typeof(double), new VoidToZeroConverter());
                csv.Configuration.TypeConverterOptionsCache.AddOptions(typeof(double), new TypeConverterOptions { NumberStyle = NumberStyles.AllowThousands });

                while (csv.Read())
                {
                    result.Add(csv.GetRecord<PreparedData>());
                }
            }

            return result;
        }

        private void saveBatch(List<PreparedData> newSet, string folder)
        {
            using (StreamWriter writer = new StreamWriter(folder + "\\next_set.csv"))
            using (var csv = new CsvWriter(writer, CultureInfo.InvariantCulture))
            {
                csv.Configuration.TypeConverterCache.AddConverter(typeof(double), new VoidToZeroConverter());
                csv.Configuration.TypeConverterOptionsCache.AddOptions(typeof(double), new TypeConverterOptions { NumberStyle = NumberStyles.AllowThousands });

                csv.WriteRecords(newSet);
            }
        }

        private void saveBatchIntoDb(List<PreparedData> batch)
        {
            List<Mesures> result = new List<Mesures>();

            batch.ForEach(set => result.Add(new Mesures(set.points, set.date,
                set.value > 0 ? set.value : 0,
                true)));

            DBManager.addPrediction(result);
        }

        public List<PreparedData> prediction(List<PreparedData> batch)
        {
            List<PreparedData> result = new List<PreparedData>();
            List<PreparedData> response;
            foreach (PreparedData set in batch)
            {
                response = caller.InvokeRequestResponseService(set).GetAwaiter().GetResult();

                result.Add(response[0]);
            }

            return result;
        }

        public async Task RunPrediction()
        {
            List<PreparedData> batch = new List<PreparedData>();
            Process r;

            DateTime lastDate = DBManager.getLastDate();

            do
            {
                batch = getNextBatch(folder);
                batch = prediction(batch);
                saveBatch(batch, folder);
                r = RunRScript(folder, "IteratingScript.r");

                r.WaitForExit();

            }
            while (DateTime.Compare(batch[0].date, lastDate) < 0);

            do
            {
                batch = getNextBatch(folder);
                batch = prediction(batch);
                saveBatchIntoDb(batch);
                saveBatch(batch, folder);
                r = RunRScript(folder, "IteratingScript.r");

                r.WaitForExit();

            }
            while (DateTime.Compare(batch[0].date, lastDate.AddMonths(MONTHS)) < 0);
        }

        Process RunRScript(string folder, string scriptName)
        {
            string rpath = pathToR + "Rscript.exe";
            string scriptpath = folder + scriptName;

            try
            {
                var info = new ProcessStartInfo
                {
                    FileName = rpath,
                    WorkingDirectory = Path.GetDirectoryName(rpath),
                    Arguments = scriptpath,
                    RedirectStandardOutput = false,
                    RedirectStandardError = false,
                    CreateNoWindow = true,
                    UseShellExecute = true
                };

                Console.WriteLine(rpath);
                Console.WriteLine(scriptpath);

                var proc = new Process { StartInfo = info };
                proc.Start();
                return proc;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            return null;
        }

        private void Proc_OutputDataReceived(object sender, DataReceivedEventArgs e)
        {
            Console.WriteLine(e.Data);
        }

        private class VoidToZeroConverter : DoubleConverter
        {
            public override object ConvertFromString(string text, IReaderRow row, MemberMapData memberMapData)
            {
                if (text == "" || text == "NA")
                {
                    return 0d;
                }
                return double.Parse(text, CultureInfo.InvariantCulture);
            }
        }
    }
}
