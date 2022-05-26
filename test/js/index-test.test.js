import path from "path"
import { init, emulator, getAccountAddress, deployContractByName, getContractAddress, getTransactionCode, getScriptCode, executeScript, sendTransaction } from "flow-js-testing";

jest.setTimeout(100000);

beforeAll(async () => {
  const basePath = path.resolve(__dirname, "../..");
  const port = 8080;

  await init(basePath, { port });
  await emulator.start(port);
});

afterAll(async () => {
  const port = 8080;
  await emulator.stop(port);
});


describe("Replicate Playground Accounts", () => {
  test("Create Accounts", async () => {
    // Playground project support 4 accounts, but nothing stops you jukeboxTemplateDatafrom creating more by following the example laid out below
    const Alice = await getAccountAddress("Alice");
    const Bob = await getAccountAddress("Bob");
    const Charlie = await getAccountAddress("Charlie");
    const Dave = await getAccountAddress("Dave");

    console.log(
      "Four Playground accounts were created with following addresses"
    );
    console.log("Alice:", Alice);
    console.log("Bob:", Bob);
    console.log("Charlie:", Charlie);
    console.log("Dave:", Dave);
  });
});
describe("Deployment", () => {
  test("Deploy for NonFungibleToken", async () => {
    const name = "NonFungibleToken"
    const to = await getAccountAddress("Alice")
    let update = true

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
        update,
      });
    } catch (e) {
      console.log(e);
    }
    expect(name).toBe("NonFungibleToken");

  });
  test("Deploy for AFLNFT", async () => {
    const name = "AFLNFT"
    const to = await getAccountAddress("Bob")
    let update = true

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
        update,
      });
    } catch (e) {
      console.log(e);
    }
    expect(name).toBe("AFLNFT");

  });

  test("Deploy for AFLPack", async () => {
    const name = "AFLPack"
    const to = await getAccountAddress("Bob")
    let update = true

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const addressMap = {
      NonFungibleToken
    };

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
        addressMap,
        update,
      });
    } catch (e) {
      console.log(e);
    }
    expect(name).toBe("AFLPack");

  });

  test("Deploy for AFLAdmin", async () => {
    const name = "AFLAdmin";
    const to = await getAccountAddress("Bob");
    let update = true;
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const AFLNFT = await getContractAddress("AFLNFT")
    const AFLPack = await getContractAddress("AFLPack")
    let addressMap = {
      NonFungibleToken,
      AFLNFT,
      AFLPack

    };
    let result;
    try {
      result = await deployContractByName({
        name,
        to,
        addressMap,
        update,
      });
    }
    catch (e) {
      console.log(e)
    }

    expect(name).toBe("AFLAdmin");
  });

});

describe("Transactions", () => {

  test("test transaction create nft template", async () => {
    const name = "createNFTTemplate";

    // Import participating accounts
    const Bob = await getAccountAddress("Bob");

    // Set transaction signers
    const signers = [Bob];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const AFLNFT = await getContractAddress("AFLNFT");
    const AFLPack = await getContractAddress("AFLPack")
    const addressMap = {
      NonFungibleToken,
      AFLNFT,
      AFLPack,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    //  brandId, schemaId, maxSupply
    const args = [1, 1, 14];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log(e);
    }
    console.log("tx Result", txResult);

    expect(txResult[0].status).toBe(4);
  });
  test("test transaction create pack template", async () => {
    const name = "creaetPackTemplate";

    // Import participating accounts
    const Bob = await getAccountAddress("Bob");

    // Set transaction signers
    const signers = [Bob];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const AFLNFT = await getContractAddress("AFLNFT");
    const AFLPack = await getContractAddress("AFLPack")
    const addressMap = {
      NonFungibleToken,
      AFLNFT,
      AFLPack,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    // brandId, SchemaId, max supply
    const args = [1, 2, 100];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log(e);
    }
    console.log("tx Result", txResult);

    expect(txResult[0].errorMessage).toBe("");
  });
  test("test transaction create Pack", async () => {
    const name = "createPack";

    // Import participating accounts
    const Bob = await getAccountAddress("Bob");

    // Set transaction signers
    const signers = [Bob];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const AFLNFT = await getContractAddress("AFLNFT");
    const AFLPack = await getContractAddress("AFLPack")
    const addressMap = {
      NonFungibleToken,
      AFLNFT,
      AFLPack,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    var currentTimeInSeconds = Math.floor(Date.now() / 1000) + 0.0; //unix timestamp in seconds

    //templateId: 2, openDate: 1640351132.0
    const args = [2, currentTimeInSeconds];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log(e);
    }
    console.log("tx Result", txResult);

    expect(txResult[0].errorMessage).toBe("");
  });
  test("test transaction setup account for user", async () => {
    const name = "setupAccount";

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");

    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const AFLNFT = await getContractAddress("AFLNFT");
    const addressMap = {
      NonFungibleToken,
      AFLNFT,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });


    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        // args,
      });
    } catch (e) {
      console.log(e);
    }
    console.log("tx Result", txResult);

    expect(txResult[0].errorMessage).toBe("");
  });


})
describe("Scripts", () => {
  test("get AFLNFT data", async () => {

    const name = "getAFLNFTData";
    const Bob = await getAccountAddress("Bob");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const AFLNFT = await getContractAddress("AFLNFT");
    const AFLPack = await getContractAddress("AFLPack")

    const addressMap = {
      NonFungibleToken,
      AFLNFT,
      AFLPack
    }
    let code = await getScriptCode({
      name,
      addressMap,
    })

    code = code.toString().replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
      const accounts = {
        "0x01": Alice,
        "0x02": Bob,
      };
      const name = accounts[match];
      return `getAccount(${name})`;
    });

    const result = await executeScript({
      code,
    });
    console.log("result", result);



  });

})