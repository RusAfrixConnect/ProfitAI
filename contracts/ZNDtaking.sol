pragma solidity ^0.8.19;

contract Zunda {
    string public constant name = "Zunda";
    string public constant symbol = "ZND";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    uint256 public constant MAX_SUPPLY = 100_000_000 * 10**18;
    
    // 🎯 TAXES OPTIMISÉES POUR MAXIMISER TES REVENUS
    uint256 public buyTax = 200;    // 2% - pour attirer les acheteurs
    uint256 public sellTax = 500;   // 5% - décourager les ventes
    uint256 public transferTax = 300; // 3% - revenus stables
    
    address public owner;
    address public treasuryWallet;
    address public ecosystemFund;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isExcludedFromTax;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event TaxCollected(uint256 amount, address indexed treasury);
    
    constructor() {
        owner = msg.sender;
        treasuryWallet = msg.sender; // 🎯 TOI comme trésorerie
        ecosystemFund = msg.sender;  // 🎯 TOI comme fond écosystème
        
        // 🎯 DISTRIBUTION INITIALE - 25% POUR TOI
        uint256 teamTokens = 25_000_000 * 10**18; // 25M ZND
        balanceOf[msg.sender] = teamTokens;
        totalSupply = teamTokens;
        
        // 🎯 EXCLUSION DES TAXES POUR TON WALLET
        isExcludedFromTax[msg.sender] = true;
        isExcludedFromTax[treasuryWallet] = true;
        
        emit Transfer(address(0), msg.sender, teamTokens);
    }
    
    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        
        uint256 taxAmount = 0;
        
        // 🎯 APPLICATION DES TAXES SAUF POUR TOI
        if (!isExcludedFromTax[msg.sender]) {
            taxAmount = (value * transferTax) / 10000;
        }
        
        uint256 netAmount = value - taxAmount;
        
        // TRANSFERT
        balanceOf[msg.sender] -= value;
        balanceOf[to] += netAmount;
        
        // 🎯 COLLECTE DES TAXES DANS TON WALLET
        if (taxAmount > 0) {
            balanceOf[treasuryWallet] += taxAmount;
            emit TaxCollected(taxAmount, treasuryWallet);
        }
        
        emit Transfer(msg.sender, to, netAmount);
        if (taxAmount > 0) {
            emit Transfer(msg.sender, treasuryWallet, taxAmount);
        }
        
        return true;
    }
    
    // 🎯 FONCTION POUR RETIRER TES REVENUS
    function withdrawRevenue(uint256 amount) external {
        require(msg.sender == owner, "Only owner");
        require(balanceOf[treasuryWallet] >= amount, "Insufficient treasury");
        
        balanceOf[treasuryWallet] -= amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(treasuryWallet, msg.sender, amount);
    }
    
    // 🎯 MODIFIER LES TAXES POUR OPTIMISER
    function setTaxes(uint256 _buy, uint256 _sell, uint256 _transfer) external {
        require(msg.sender == owner, "Only owner");
        buyTax = _buy;
        sellTax = _sell;
        transferTax = _transfer;
    }
    
    // 🎯 EXCLURE DES ADRESSES DES TAXES (PARTENAIRES)
    function excludeAddress(address account, bool excluded) external {
        require(msg.sender == owner, "Only owner");
        isExcludedFromTax[account] = excluded;
    }
}