
const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
console.log('Arguments:', args);

let destFile = args[0];
if (destFile === undefined) {
    console.error("No preprocess configuration file specified");
    process.exit(-1);
}

console.log(`Preprocessing files based on the configuration defined in ${destFile}....`);



try {
  const data = fs.readFileSync(destFile, 'utf8');
  console.log(data);

  for (const line of data.split(/\r?\n/)) {
    console.log(`Processing line: ${line}`);
    let parts = line.split(/\s+/);
    let destFile = parts.shift();
    if (destFile === undefined || destFile === '') {
      continue;
    }
    console.log(`Destination file is ${destFile}`);
    let origFileLines = fs.readFileSync(path.join(__dirname, destFile), 'utf8').split(/\r?\n/);
    let outputContent = '';

    for(const origFileLine of origFileLines){ 
      if(origFileLine.trim() == '----') {
        outputContent += '----\n';
        break;
      } 
        outputContent += (origFileLine + '\n');
    }

    let inputFile = undefined;
    while(inputFile = parts.shift()) {
      console.log(`  Processing input file: ${inputFile}`);
      
      let inFileLines = fs.readFileSync(path.join(__dirname, inputFile), 'utf8').split(/\r?\n/);
      for(const line of inFileLines) {
        if(line.startsWith('-- ')) {
          outputContent += (line.slice(3) + '\n');
        }
      }
      
      fs.writeFileSync(path.join(__dirname, destFile), outputContent, 'utf8');
    }
  }
  console.log('Preprocessing completed successfully!');
} catch (err) {
  console.error("An error occurred:", err);
}