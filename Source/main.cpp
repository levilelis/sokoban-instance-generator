#include "stdafx.h"

using namespace std;
using namespace ls;

ls::TypeHeuristic HeuristicType(string heuristic)
{
	ls::TypeHeuristic type_heuristic;

	// A -- Simple heuristic

	if (heuristic == "pdb1")
		return type_heuristic = ls::TypeHeuristic::pdb1;
	else if (heuristic == "pdb2")
		return type_heuristic = ls::TypeHeuristic::pdb2;
	else if (heuristic == "pdb3r")
		return type_heuristic = ls::TypeHeuristic::pdb3r;
	else if (heuristic == "pdb4r")
		return type_heuristic = ls::TypeHeuristic::pdb4r;

	// B -- Heuristic + Conflicts

	else if (heuristic == "pdb2_2oc") //[PDB2, PDB2-PDB1]
		return type_heuristic = ls::TypeHeuristic::pdb2_oc2;
	else if (heuristic == "pdb3r_3ocr") //[PDB3r, PDB3r-PDB2]
		return type_heuristic = ls::TypeHeuristic::pdb3r_oc3r;
	else if (heuristic == "pdb4r_4ocr") //[PDB4r, PDB4r-PDB3r]
		return type_heuristic = ls::TypeHeuristic::pdb4r_oc4r;

	// C -- Conflicts + Heuristic

	else if (heuristic == "2oc_pdb2") //[PDB2-PDB1,PDB2]
		return type_heuristic = ls::TypeHeuristic::oc2_pdb2;
	else if (heuristic == "3ocr_pdb3r") //[PDB3r-PDB2,PDB3r]
		return type_heuristic = ls::TypeHeuristic::oc3r_pdb3r;
	else if (heuristic == "4ocr_pdb4r") //[PDB4r-PDB3r,PDB4r]
		return type_heuristic = ls::TypeHeuristic::oc4r_pdb4r;

	// D -- Novelty + Heuristic

	else if (heuristic == "wpdb1_pdb1") //[w(PDB1),PDB1]
		return type_heuristic = TypeHeuristic::wpdb1_pdb1;
	else if (heuristic == "wpdb2_pdb2") //[w(PDB2),PDB2]
		return type_heuristic = ls::TypeHeuristic::wpdb2_pdb2;
	else if (heuristic == "wpdb3r_pdb3r") //[w(PDB3r),PDB3r]
		return type_heuristic = ls::TypeHeuristic::wpdb3r_pdb3r;
	else if (heuristic == "wpdb4r_pdb4r") //[w(PDB4r),PDB4r]
		return type_heuristic = ls::TypeHeuristic::wpdb4r_pdb4r;

	// E -- Novelty + Heuristic + Conflicts

	else if (heuristic == "wpdb2_pdb2_2oc") // [w(PDB2),PDB2,PDB2-PDB1]
			return type_heuristic = ls::TypeHeuristic::wpdb2_pdb2_oc2;
	else if (heuristic == "wpdb3r_pdb3r_3ocr") // [w(PDB3r),PDB3r,PDB3r-PDB2]
		return type_heuristic = ls::TypeHeuristic::wpdb3r_pdb3r_oc3r;
	else if (heuristic == "wpdb4r_pdb4r_4ocr") // [w(PDB4r),PDB4r,PDB4r-PDB3r]
		return type_heuristic = ls::TypeHeuristic::wpdb4r_pdb4r_oc4r;

	// F -- Novelty + Conflicts + Heuristic

	else if (heuristic == "wpbd2_2oc_pdb2") // [w(PDB2),PDB2-PDB1,PDB2]
		return type_heuristic = ls::TypeHeuristic::wpdb2_oc2_pdb2;
	else if (heuristic == "wpbd3r_3ocr_pdb3r") // [w(PDB3r),PDB3r-PDB2,PDB3r]
		return type_heuristic = ls::TypeHeuristic::wpdb3r_oc3r_pdb3r;
	else if (heuristic == "wpdb4r_4ocr_pdb4r") // [w(PDB4r),PDB4r-PDB3r,PDB4r]
		return type_heuristic = ls::TypeHeuristic::wpdb4r_oc4r_pdb4r;

	std::cerr << "Error: unknown ORDERING '" << heuristic << "'. See README.md for the list of orderings." << std::endl;
	std::exit(1);
}

// Orderings that use PDB2 (directly, or through 2C/3C conflicts) need Blossom V.
bool RequiresBlossom(ls::TypeHeuristic type)
{
	switch (type)
	{
		case ls::TypeHeuristic::pdb2:
		case ls::TypeHeuristic::pdb2_oc2:
		case ls::TypeHeuristic::pdb3r_oc3r:
		case ls::TypeHeuristic::oc2_pdb2:
		case ls::TypeHeuristic::oc3r_pdb3r:
		case ls::TypeHeuristic::wpdb2_pdb2:
		case ls::TypeHeuristic::wpdb2_pdb2_oc2:
		case ls::TypeHeuristic::wpdb3r_pdb3r_oc3r:
		case ls::TypeHeuristic::wpdb2_oc2_pdb2:
		case ls::TypeHeuristic::wpdb3r_oc3r_pdb3r:
			return true;
		default:
			return false;
	}
}

void CaseRunInstanceMethod(char* argv[])
{
   //Read files.
   std::string file = argv[1];
   ls::Reader reader(file);

   //Read algorithm
   ls::TypeTest type_test = ls::TypeTest::GBFS;

   // Read heuristic
   std::string heuristic = argv[2];
   ls::TypeHeuristic type_heuristic = HeuristicType(heuristic);
#ifndef USE_BLOSSOM
   if (RequiresBlossom(type_heuristic))
   {
      std::cerr << "Error: ORDERING '" << heuristic << "' uses PDB2, which requires Blossom V." << std::endl
                << "Rebuild with `make BLOSSOM=1` (see README.md), or use an ordering based on PDB1, PDB3, or PDB4." << std::endl;
      std::exit(1);
   }
#endif

   //Read time
   std::string TIME = argv[3];
   const int LIMIT_TIME = std::stoi(TIME);

   std::string run_time = argv[4];

   // -------------- Printing the results on the files -----------------------------------------------
   // Creation of the files and folders to store the results
   std::string base_folder = "Results/" + run_time + "/";
   std::string heuristic_folder = base_folder + "GBFS-" + heuristic + "-" + TIME;
   mkdir(base_folder.c_str(), 0777);
   mkdir(heuristic_folder.c_str(), 0777);

   std::string folder_results_distances = heuristic_folder + "/Distances/";
   std::string folder_results_instances = heuristic_folder + "/Instances/";
   mkdir(folder_results_distances.c_str(), 0777);
   mkdir(folder_results_instances.c_str(), 0777);

   std::ofstream out_distances(folder_results_distances + file + "-GBFS-" + heuristic + ".txt");
   std::ofstream out_instances(folder_results_instances + file + ".map");

   //Put the number of instance on the file of the result
   out_instances << "!" << file[9] << file[10] << std::endl;
   out_distances << file[9] << file[10] << " GBFS " << heuristic << " ";

   //out_all_distances << "# MEMORY EXPANDED MM PDB1 IPDB2 IPDB3 IPDB4 MPDB2 MPDB3 MPDB4 TIME" << std::endl;
   // ----------------------------------------------------------------------------------------------------

   srand(time(NULL));

   //Run tests.
   for (int i = 0; i < reader.Size(); i++)
   {
      // Pre-Processing the instance.
      ls::Instance instance;
      std::vector<std::string> instace_file(reader.Instace(i));
      std::vector<int> root = instance.ProcessInstance(instace_file);

      //Generate the instance
      ls::GenerateInstance test_case(instance, LIMIT_TIME, type_heuristic);
      std::vector<int> results = test_case.RunHS(file, root, instance, type_heuristic, type_test, out_distances, out_instances);

   }

   out_distances.close();
   out_instances.close();

}


int main(int argc, char* argv[])
{
   if (argc != 5)
   {
      std::cerr << "Usage: " << argv[0] << " <NAME> <ORDERING> <TIME> <RUN>" << std::endl
                << "Example: " << argv[0] << " instance_01 wpdb4r_4ocr_pdb4r 60 01" << std::endl
                << "See README.md for details." << std::endl;
      return 1;
   }

   CaseRunInstanceMethod(argv);
   return 0;
}
