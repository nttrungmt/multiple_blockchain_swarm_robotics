const { exec } = require('child_process');


function startGeths(robot){
	exec(` geth --datadir ./blockchains/surveyChain/peer${robot}DataDir init ./blockchains/surveyChain/Genesis.json`, (err, stdout, stderr) => {
	  if (err) {
	    // node couldn't execute the command
	    console.log(err);
	    return;
	  }

	  // the *entire* stdout and stderr (buffered)
	  console.log(`stdout: ${stdout}`);
	  console.log(`stderr: ${stderr}`);
	});
}


function launchGeths(robot){
	exec(`geth --exec --verbosity 6 --networkid 2 --ipcpath="./blockchains/surveyChain/peer${robot}DataDir/geth.ipc"  --datadir="./blockchains/surveyChain/peer${robot}DataDir"  --port ${30303+robot} --rpcport ${8100+robot} --maxpeers 130 &`, (err, stdout, stderr) => {
	  if (err) {
	    // node couldn't execute the command
	    console.log(err);
	    return;
	  }

	  // the *entire* stdout and stderr (buffered)
	  console.log(`stdout: ${stdout}`);
	  console.log(`stderr: ${stderr}`);
	});
}

function rmGeths(robot){
	exec(`rm -r ./blockchains/surveyChain/peer${robot}DataDir`, (err, stdout, stderr) => {
	  if (err) {
	    // node couldn't execute the command
	    console.log(err);
	    return;
	  }

	  // the *entire* stdout and stderr (buffered)
	  console.log(`stdout: ${stdout}`);
	  console.log(`stderr: ${stderr}`);
	});
}

for(var i=1; i< 4; i++){
	rmGeths(i);
	startGeths(i);
	launchGeths(i);
	console.log("started");
}