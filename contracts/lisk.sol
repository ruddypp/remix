// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LiskGarden {

    // ============================================
    // BAGIAN 1: ENUM & STRUCT
    // ============================================
    // TODO 1.1: Buat enum GrowthStage dengan 4 nilai:
    // SEED, SPROUT, GROWING, BLOOMING
    // Hint: enum GrowthStage { SEED, SPROUT, GROWING, BLOOMING }
    enum Growthstage{
        SEED,
        SPROUT,
        GROWING,
        BLOOMING
    }

    // TODO 1.2: Buat struct Plant dengan 8 fields:
    // - uint256 id
    // - address owner
    // - GrowthStage stage
    // - uint256 plantedDate
    // - uint256 lastWatered
    // - uint8 waterLevel
    // - bool exists
    // - bool isDead

    struct Plant{
        uint256 id;
        address owner;
        Growthstage stage;
        uint256 plantedDate;
        uint256 lastWatered;
        uint8 waterLevel;
        bool exists;
        bool isDead;
    }

    // ============================================
    // BAGIAN 2: STATE VARIABLES
    // ============================================
    // TODO 2.1: Mapping plantId ke Plant
    // Hint: mapping(uint256 => Plant) public plants;
    mapping(uint256 => Plant) public plants;

    // TODO 2.2: Mapping address ke array plantId (track tanaman user)
    // Hint: mapping(address => uint256[]) public userPlants;
    mapping(address => uint256[]) public userPlants;


    // TODO 2.3: Counter untuk ID tanaman baru
    // Hint: uint256 public plantCounter;
    uint256 public plantCounter;


    // TODO 2.4: Address owner contract
    // Hint: address public owner;
    address public owner;


    // ============================================
    // BAGIAN 3: CONSTANTS (Game Parameters)
    // ============================================
    // TODO 3.1: Harga tanam = 0.001 ether
    // Hint: uint256 public constant PLANT_PRICE = 0.001 ether;
    uint256 public constant PLANT_PRICE = 0.001 ether;

    // TODO 3.2: Reward panen = 0.003 ether
    uint256 public constant HARVEST_REWARD = 0.003 ether;


    // TODO 3.3: Durasi per stage = 1 menit
    // Hint: uint256 public constant STAGE_DURATION = 1 minutes;
    uint256 public constant STAGE_DURATION = 1 minutes;


    // TODO 3.4: Waktu deplesi air = 30 detik
    uint256 public constant WATER_DEPLETION_TIME = 30 seconds;


    // TODO 3.5: Rate deplesi = 2 (2% setiap interval)
    // Hint: uint8 public constant WATER_DEPLETION_RATE = 2;
    uint8 public constant WATER_DEPLETION_RATE = 2;


    // ============================================
    // BAGIAN 4: EVENTS
    // ============================================
    // TODO 4.1: Event PlantSeeded(address indexed owner, uint256 indexed plantId)
    event PlantSeeded(address indexed owner, uint256 indexed plantId);


    // TODO 4.2: Event PlantWatered(uint256 indexed plantId, uint8 newWaterLevel)
    event PlantWatered(uint256 indexed plantId, uint8 newWaterLevel);

    // TODO 4.3: Event PlantHarvested(uint256 indexed plantId, address indexed owner, uint256 reward)
    event PlantHarvested(uint256 indexed plantId, address indexed owner, uint256 reward);

    // TODO 4.4: Event StageAdvanced(uint256 indexed plantId, GrowthStage newStage)
    event StageAdvanced(uint256 indexed plantId, Growthstage newStage);

    // TODO 4.5: Event PlantDied(uint256 indexed plantId)
    event PlantDied(uint256 indexed plantId);

    // ============================================
    // BAGIAN 5: CONSTRUCTOR
    // ============================================
    // TODO 5: Set owner = msg.sender
    constructor() {
        owner = msg.sender;
    }

    // ============================================
    // BAGIAN 6: PLANT SEED (Fungsi Utama #1)
    // ============================================
    // TODO 6: Lengkapi fungsi plantSeed
    // Tipe: external payable, returns uint256
    // Steps:
    // 1. require msg.value >= PLANT_PRICE
    // 2. Increment plantCounter
    // 3. Buat Plant baru dengan struct
    // 4. Simpan ke mapping plants
    // 5. Push plantId ke userPlants
    // 6. Emit PlantSeeded
    // 7. Return plantId
    function plantSeed() external payable returns (uint256) {
        // TODO: Implement fungsi ini
        // Hint: Lihat spesifikasi di atas!
        require(msg.value >= PLANT_PRICE,"Saldo Kurang Banh");
        plantCounter++;
        Plant memory newPlant = Plant({
        id: plantCounter,
        owner : msg.sender,
        stage : Growthstage.SEED,
        plantedDate : block.timestamp,
        lastWatered : block.timestamp,
        waterLevel : 100,
        exists : true,
        isDead : false
    });
    plants[plantCounter] = newPlant;
    userPlants[msg.sender].push(plantCounter);
    emit PlantSeeded(msg.sender, plantCounter);
    return plantCounter;
    }

    // ============================================
    // BAGIAN 7: WATER SYSTEM (3 Fungsi)
    // ============================================

    // TODO 7.1: calculateWaterLevel (public view returns uint8)
    // Steps:
    // 1. Ambil plant dari storage
    // 2. Jika !exists atau isDead, return 0
    // 3. Hitung timeSinceWatered = block.timestamp - lastWatered
    // 4. Hitung depletionIntervals = timeSinceWatered / WATER_DEPLETION_TIME
    // 5. Hitung waterLost = depletionIntervals * WATER_DEPLETION_RATE
    // 6. Jika waterLost >= waterLevel, return 0
    // 7. Return waterLevel - waterLost

    function calculateWaterLevel(uint256 plantId) public view returns (uint8) {
        // TODO: Implement
        Plant storage plant = plants[plantId];
        if (!plant.exists||plant.isDead){
            return 0;
        }
        uint256 timeSinceWatered = block.timestamp - plant.lastWatered;
        uint256 depletionIntervals = timeSinceWatered / WATER_DEPLETION_TIME;
        uint256 waterLost = depletionIntervals * WATER_DEPLETION_RATE;

        if(waterLost >= plant.waterLevel){
            return 0;
        }
        return uint8(plant.waterLevel - waterLost);
    }

    // TODO 7.2: updateWaterLevel (internal)
    // Steps:
    // 1. Ambil plant dari storage
    // 2. Hitung currentWater dengan calculateWaterLevel
    // 3. Update plant.waterLevel
    // 4. Jika currentWater == 0 && !isDead, set isDead = true dan emit PlantDied

    function updateWaterLevel(uint256 plantId) internal {
        // TODO: Implement
        Plant storage plant = plants[plantId];
        uint8 currentWater = calculateWaterLevel(plantId);
        plant.waterLevel = currentWater;
        if(currentWater == 0 && !plant.isDead){
            plant.isDead = true;
            emit PlantDied(plantId);
        }
    }

    // TODO 7.3: waterPlant (external)
    // Steps:
    // 1. require exists
    // 2. require owner == msg.sender
    // 3. require !isDead
    // 4. Set waterLevel = 100
    // 5. Set lastWatered = block.timestamp
    // 6. Emit PlantWatered
    // 7. Call updatePlantStage

    function waterPlant(uint256 plantId) external {
        // TODO: Implement
        Plant storage plant = plants[plantId];
        require(plant.exists);
        require(plant.owner == msg.sender);
        require(!plant.isDead);
        plant.waterLevel = 100;
        plant.lastWatered = block.timestamp;
        emit PlantWatered(plantId, plant.waterLevel);
        updatePlantStage(plantId);
    }

    // ============================================
    // BAGIAN 8: STAGE & HARVEST (2 Fungsi)
    // ============================================

    // TODO 8.1: updatePlantStage (public)
    // Steps:
    // 1. require exists
    // 2. Call updateWaterLevel
    // 3. Jika isDead, return
    // 4. Hitung timeSincePlanted
    // 5. Simpan oldStage
    // 6. Update stage berdasarkan waktu (3 if statements)
    // 7. Jika stage berubah, emit StageAdvanced

    function updatePlantStage(uint256 plantId) public {
        // TODO: Implement
        Plant storage plant = plants[plantId];
        require(plant.exists);
        updateWaterLevel(plantId);
        if(plant.isDead) return ;
        uint256 timeSincePlanted = block.timestamp - plant.plantedDate;
        Growthstage oldStage = plant.stage;
        if (timeSincePlanted >= 3 * STAGE_DURATION) {
        plant.stage = Growthstage.BLOOMING;
        } else if (timeSincePlanted >= 2 * STAGE_DURATION) {
        plant.stage = Growthstage.GROWING;
        } else if (timeSincePlanted >= 1 * STAGE_DURATION) {
        plant.stage = Growthstage.SPROUT;
        } else {
        plant.stage = Growthstage.SEED;
        }

        if(plant.stage != oldStage){
            emit StageAdvanced(plantId, plant.stage);
        }

    }

    // TODO 8.2: harvestPlant (external)
    // Steps:
    // 1. require exists
    // 2. require owner
    // 3. require !isDead
    // 4. Call updatePlantStage
    // 5. require stage == BLOOMING
    // 6. Set exists = false
    // 7. Emit PlantHarvested
    // 8. Transfer HARVEST_REWARD dengan .call
    // 9. require success

    function harvestPlant(uint256 plantId) external {
        // TODO: Implement
        Plant storage plant = plants[plantId];
        require(plant.exists);
        require(plant.owner == msg.sender);
        require(!plant.isDead, "Tanaman sudah mati");
        updatePlantStage(plantId);
        require (plant.stage == Growthstage.BLOOMING);
        plant.exists = false;
        emit PlantHarvested(plantId,msg.sender, HARVEST_REWARD);
        (bool success, ) = msg.sender.call{value: HARVEST_REWARD}("");
        require(success, "Transfer gagal");





    }

    // ============================================
    // HELPER FUNCTIONS (Sudah Lengkap)
    // ============================================

    function getPlant(uint256 plantId) external view returns (Plant memory) {
        Plant memory plant = plants[plantId];
        plant.waterLevel = calculateWaterLevel(plantId);
        return plant;
    }

    function getUserPlants(address user) external view returns (uint256[] memory) {
        return userPlants[user];
    }

    function withdraw() external {
        require(msg.sender == owner, "Bukan owner");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer gagal");
    }

    receive() external payable {}
}