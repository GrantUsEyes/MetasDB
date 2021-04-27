<!DOCTYPE HTML>
<?php $sim = ""; $run = "";?>
<html>
	<header><h1>Welcome to MetasDB</h1>
	<h4>Cancer-associated fibroblasts are an area of specific interest in the realm of cancer research. These fibroblasts have been found to speed up (and occasionally slow down) the spread of cancer. Understanding the effect that CAFs have on cancer metastasis may be crucial to develop anti-metastasis drugs to combat the spread of a tumor within a patient. To better investigate CAFs' role in tumor metastasis, we can use computational biology to simulate the interactions between CAFs and tumor cells within the tumor microenvironment. The intention of MetasDB is to store and analyze the results of the simulations in a way that are queryable to the user.<br><br> </h4></header>
	
	<body>
		<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>">
			Which Simulation data would you like to test (1/2/3)?:  			<input type="text" id="sim" name="sim"><br><br>
			<button type="submit" value="Submit">Submit</button><br><br>
			BE ADVISED: This site will convert a .csv file into a .sql to be analyzed every time a simulation is chosen, to preserve memory space in the server. The contents of the .csv files are quite large and therefore processing these documents may take a little bit of time.
		</form>
<?php 
if($_SERVER["REQUEST_METHOD"] == "POST") {
	if(empty($_POST["sim"])){
		echo "Please enter the number of the simulation you would like to test.";
	}
	else {
		$sim = $_POST["sim"];
		if($sim == 1) {
			system($run);
		}
	}
}

?>

</body>
</html>
