using PowerBranch.Models;
using System;

namespace PowerBranch
{
    class Program
    {
        static void Main(string[] args)
        {
            PowerBranchContext context = new PowerBranchContext();
            DatabaseManager databaseManager = new DatabaseManager(context);
            PredictionManager predictionManager = new PredictionManager(databaseManager);

            predictionManager.RunPrediction();
        }
    }
}
