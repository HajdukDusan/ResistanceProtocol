const fs = require("fs");
const path = require("path");

const getTheAbi = (contractName) => {
  try {
    const dir = path.resolve(
      __dirname,
      "../artifacts/contracts/" +
        contractName +
        ".sol/" +
        contractName +
        ".json"
    );
    const file = fs.readFileSync(dir, "utf8");
    const json = JSON.parse(file);
    const abi = json.abi;

    return abi;
  } catch (e) {
    console.log(`e`, e);
  }
};

const writeAbiAndAddress = (contractName,address) => {
  try {
    const dir = path.resolve(
      __dirname,
      "../artifacts/contracts/" +
        contractName +
        ".sol/" +
        contractName +
        ".json"
    );
    const file = fs.readFileSync(dir, "utf8");
    const json = JSON.parse(file);
    const abi = json.abi;

    const dirWrite = path.resolve(
      __dirname,
      "../../frontend/src/contracts/"+contractName+".js"
    );

    fs.writeFile(dirWrite, "export const ABI= "+JSON.stringify(abi,null,2)+"\nexport const address= \""+address+"\"", (err) => {
      if (err) {
        console.log(err);
      }
    });

    return abi;
  } catch (e) {
    console.log(`e`, e);
  }
};

module.exports = { getTheAbi, writeAbiAndAddress };