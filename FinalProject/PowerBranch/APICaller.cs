// This code requires the Nuget package Microsoft.AspNet.WebApi.Client to be installed.
// Instructions for doing this in Visual Studio:
// Tools -> Nuget Package Manager -> Package Manager Console
// Install-Package Microsoft.AspNet.WebApi.Client

using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace PowerBranch
{
    public class APICaller
    {

        public async Task<List<PreparedData>> InvokeRequestResponseService(PreparedData data)
        {
            NumberFormatInfo nfi = new NumberFormatInfo();
            nfi.NumberDecimalSeparator = ".";
            using (var client = new HttpClient())
            {
                var scoreRequest = new
                {
                    Inputs = new Dictionary<string, List<Dictionary<string, string>>>() {
                        {
                            "input1",
                            new List<Dictionary<string, string>>(){new Dictionary<string, string>(){
                                            {
                                                "points", data.points
                                            },
                                            {
                                                "date", data.date.ToString("MM-dd-yyyy hh:mm tt")
                                            },
                                            {
                                                "value", data.value.ToString(nfi)
                                            },
                                            {
                                                "x", data.x.ToString(nfi)
                                            },
                                            {
                                                "y", data.y.ToString(nfi)
                                            },
                                            {
                                                "valuePrec1", data.valuePrec1.ToString(nfi)
                                            },
                                            {
                                                "valuePrec2", data.valuePrec2.ToString(nfi)
                                            },
                                            {
                                                "neighbours1value", data.neighbours1value.ToString(nfi)
                                            },
                                            {
                                                "neighbours1valuePrec1", data.neighbours1valuePrec1.ToString(nfi)
                                            },
                                            {
                                                "neighbours1valuePrec2", data.neighbours1valuePrec2.ToString(nfi)
                                            },
                                            {
                                                "neighbours2value", data.neighbours2value.ToString(nfi)
                                            },
                                            {
                                                "neighbours2valuePrec1", data.neighbours2valuePrec1.ToString(nfi)
                                            },
                                            {
                                                "neighbours2valuePrec2", data.neighbours2valuePrec2.ToString(nfi)
                                            },
                                            {
                                                "neighbours3value", data.neighbours3value.ToString(nfi)
                                            },
                                            {
                                                "neighbours3valuePrec1", data.neighbours3valuePrec1.ToString(nfi)
                                            },
                                            {
                                                "neighbours3valuePrec2", data.neighbours3valuePrec2.ToString(nfi)
                                            },
                                }
                            }
                        },
                    },
                    GlobalParameters = new Dictionary<string, string>()
                    {
                    }
                };

                const string apiKey = "BixcvkcLGsVUJlitVl4gs2VjApcftnsD5bPfG/4OY/wsktrublBFmydwvpC8e1fWiYfGFEJFKkt/qvQvdbWfaQ=="; // Replace this with the API key for the web service
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
                client.BaseAddress = new Uri("https://ussouthcentral.services.azureml.net/workspaces/11276de4c55c44f2a2c5f0c21a98dcbc/services/6f3f20babb3744a2ba51b495c63c86bb/execute?api-version=2.0&format=swagger");

                // WARNING: The 'await' statement below can result in a deadlock
                // if you are calling this code from the UI thread of an ASP.Net application.
                // One way to address this would be to call ConfigureAwait(false)
                // so that the execution does not attempt to resume on the original context.
                // For instance, replace code such as:
                //      result = await DoSomeTask()
                // with the following:
                //      result = await DoSomeTask().ConfigureAwait(false)

                HttpResponseMessage response = await client.PostAsJsonAsync("", scoreRequest);

                if (response.IsSuccessStatusCode)
                {
                    List<PreparedData> resultDatas = new List<PreparedData>();
                    string result = await response.Content.ReadAsStringAsync();
                    ResultContainer outputs = JsonConvert.DeserializeObject<ResultContainer>(result);

                    foreach(APIOutput output in outputs.Results.output1)
                    {
                        resultDatas.Add(new PreparedData(data.points, output.date, output.ScoredLabels > 0 ? output.ScoredLabels : 0,
                            data.x, data.y, data.valuePrec1, data.valuePrec2, 0,
                            data.neighbours1valuePrec1, data.neighbours1valuePrec2, 0, data.neighbours1valuePrec1, data.neighbours1valuePrec2,
                            0, data.neighbours3valuePrec1, data.neighbours3valuePrec2));
                    }

                    return resultDatas;
                }
                else
                {
                    Console.WriteLine(string.Format("The request failed with status code: {0}", response.StatusCode));

                    // Print the headers - they include the requert ID and the timestamp,
                    // which are useful for debugging the failure
                    Console.WriteLine(response.Headers.ToString());

                    string responseContent = await response.Content.ReadAsStringAsync();
                    Console.WriteLine(responseContent);

                    return null;
                }
            }
        }
    }
}