<!DOCTYPE HTML>
<?php $sim = ""; $run = "";?>
<html>
	<header><h1>Welcome to MetasDB</h1>
	<h4>Cancer-associated fibroblasts are an area of specific interest in the realm of cancer research. These fibroblasts have been found to speed up (and occasionally slow down) the spread of cancer. Understanding the effect that CAFs have on cancer metastasis may be crucial to develop anti-metastasis drugs to combat the spread of a tumor within a patient. To better investigate CAFs' role in tumor metastasis, we can use computational biology to simulate the interactions between CAFs and tumor cells within the tumor microenvironment. The intention of MetasDB is to store and analyze the results of the simulations in a way that are queryable to the user.<br><br> </h4></header>
	
	<body>
		<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>">
			Which Simulation data would you like to test (1/2/3)?:  			<input type="text" id="sim" name="sim"><br><br>
			<button type="submit" value="Submit">Submit</button><br><br>
			<p style="color:red;">BE ADVISED: This site will convert a .csv file into a .sql file to be analyzed every time a simulation is chosen, to preserve memory space in the server. The contents of the .csv files are quite large and therefore processing these documents may take a little bit of time. If this is your first time here it is highly recommended that you read the<a href="odin.unomaha.edu/~zwright/metasFAQ.php">FAQ</a></p>
		</form>
<?php //Runs the python script processInput.py with the input depending on the chosen simulation and then queries the system to analyze the data from the simulation.
if($_SERVER["REQUEST_METHOD"] == "POST") {
	if(empty($_POST["sim"])){
		echo "Please enter the number of the simulation you would like to test.";
	}
	else {
		$sim = $_POST["sim"];
		if($sim == 1) {
			$run = "python3 Final_project/processInput.py -i Final_project/Simulations/Simulation1.csv -o Final_project/MetasDB.sql";
		}
		else if($sim == 2) {
			$run = "python3 Final_project/processInput.py -i Final_project/Simulations/Simulation2.csv -o Final_project/MetasDB.sql";
		}
		else if($sim == 3) {
			$run = "python3 Final_project/processInput.py -i Final_project/Simulations/Simulation3.csv -o Final_project/MetasDB.sql";
		}
		else {
			echo "Sorry there are only currently 3 simulations in the folder.";
			break;
		}
		$system($run);
		$system("mysql < MetasDB.sql");

	}
}
$server="localhost";
$username="zwright";
$password="";
$database="zwright";

$connect= mysqli_connect($server,$password,$database);
if($connect -> connect_error){
	echo "Failed to connect";
	echo "Connection Error:" .$connect->connect_error;
}
//Max steps taken until metastasizing.
$query = "SELECT max(lsteps) from MetasDB;";
$result = mysqli_query($connect, $query)
	or trigger_error("Query Failed! SQL: $query - Error: "
	. mysqli_error($connect), E_USER_ERROR);
if($result = mysqli_query($connect,$query)) {
	while($row = mysqli_fetch_row($result)) {
		printf("<br><br>The maximum number of steps taken in the simulation to metastasize is %s steps<br><br>", $row[0]);
	}
}

//Min steps taken until metastasizing
$query = "SELECT min(lsteps) from MetasDB;";
$result = mysqli_query($connect, $query)
	or trigger_error("Query Failed! SQL: $query - Error: "
	. mysqli_error($connect), E_USER_ERROR);
if($result = mysqli_query($connect,$query)) {
	while($row = mysqli_fetch_row($result)) {
		printf("<br><br>The minimum number of steps taken in the simulation to metastasize is %s steps<br><br>", $row[0]);
	}
}

//Max steps taken until metastasizing with CAFs set to on
$query = "SELECT max(lsteps) from MetasDB where CAFS_toggled=TRUE;";
$result = mysqli_query($connect, $query)
	or trigger_error("Query Failed! SQL: $query - Error: "
	. mysqli_error($connect), E_USER_ERROR);
if($result = mysqli_query($connect,$query)) {
	while($row = mysqli_fetch_row($result)) {
		printf("<br><br>The minimum number of steps taken in the simulation to metastasize with CAFs ON is %s steps<br><br>", $row[0]);
	}
}

//Min steps taken until metastasizing with CAFs set to on
$query = "SELECT min(lsteps) from MetasDB where CAFS_toggled=TRUE;";
$result = mysqli_query($connect, $query)
	or trigger_error("Query Failed! SQL: $query - Error: "
	. mysqli_error($connect), E_USER_ERROR);
if($result = mysqli_query($connect,$query)) {
	while($row = mysqli_fetch_row($result)) {
		if($row[0] == "NULL")
		{
			$row[0] = 0;
		}
		printf("<br><br>The minimum number of steps taken in the simulation to metastasize with CAFs ON is %s steps<br><br>", $row[0]);
	}
}

//Max steps taken until metastasizing with CAFs set to off
$query = "SELECT min(lsteps) from MetasDB where CAFS_toggled=TRUE;";
$result = mysqli_query($connect, $query)
	or trigger_error("Query Failed! SQL: $query - Error: "
	. mysqli_error($connect), E_USER_ERROR);
if($result = mysqli_query($connect,$query)) {
	while($row = mysqli_fetch_row($result)) {
		if($row[0] == "NULL")
		{
			$row[0] = 0;
		}
		printf("<br><br>The maximum number of steps taken in the simulation to metastasize with CAFs OFF is %s steps<br><br>", $row[0]);
	}
}

//Min steps taken until metastasizing with CAFs set to off
$query = "SELECT min(lsteps) from MetasDB where CAFS_toggled=TRUE;";
$result = mysqli_query($connect, $query)
	or trigger_error("Query Failed! SQL: $query - Error: "
	. mysqli_error($connect), E_USER_ERROR);
if($result = mysqli_query($connect,$query)) {
	while($row = mysqli_fetch_row($result)) {
		if($row[0] == "NULL")
		{
			$row[0] = 0;
		}
		printf("<br><br>The minimum number of steps taken in the simulation to metastasize with CAFs OFF is %s steps<br><br>", $row[0]);
	}
}

//Overall average number of steps until metastasis
$query = "SELECT avg(lsteps) from MetasDB;";
$result = mysqli_query($connect, $query)
	or trigger_error("Query Failed! SQL: $query - Error: "
	. mysqli_error($connect), E_USER_ERROR);
if($result = mysqli_query($connect,$query)) {
	while($row = mysqli_fetch_row($result)) {
		printf("<br><br>The average number of steps taken in the simulation to metastasize is %s steps<br><br>", $row[0]);
	}
}

//Average number of steps until metastasis with CAFs on
$query = "SELECT avg(lsteps) from MetasDB where CAFS_toggled=TRUE;";
$result = mysqli_query($connect, $query)
	or trigger_error("Query Failed! SQL: $query - Error: "
	. mysqli_error($connect), E_USER_ERROR);
if($result = mysqli_query($connect,$query)) {
	while($row = mysqli_fetch_row($result)) {
		printf("<br><br>The average number of steps taken in the simulation to metastasize is %s steps<br><br>", $row[0]);
	}
}

//Average number of steps until metastasis with CAFS off
$query = "SELECT avg(lsteps) from MetasDB where CAFS_toggled=FALSE;";
$result = mysqli_query($connect, $query)
	or trigger_error("Query Failed! SQL: $query - Error: "
	. mysqli_error($connect), E_USER_ERROR);
if($result = mysqli_query($connect,$query)) {
	while($row = mysqli_fetch_row($result)) {
		printf("<br><br>The average number of steps taken in the simulation to metastasize is %s steps<br><br>", $row[0]);
	}
}

//Average number of CAFs across all runs with CAFs on
$query = "SELECT avg(CAF_count) from MetasDB where CAFS_toggled=TRUE;";
$result = mysqli_query($connect, $query)
	or trigger_error("Query Failed! SQL: $query - Error: "
	. mysqli_error($connect), E_USER_ERROR);
if($result = mysqli_query($connect,$query)) {
	while($row = mysqli_fetch_row($result)) {
		printf("<br><br>The average number of CAFs in the simulation with CAFs ON is %s CAFs<br><br>", $row[0]);
	}
}

?>

</body>
</html>
