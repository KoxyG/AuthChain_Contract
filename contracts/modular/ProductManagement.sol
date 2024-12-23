// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract ProductManagement {
    
    enum ProductStatus {
        MANUFACTURED,         
        IN_TRANSIT_TO_LOGISTICPERSONNEL,  
        IN_TRANSIT_TO_RETAILER, 
        WITH_RETAILER,      
        SOLD_TO_CONSUMER,    
        RETURNED,  
        RECALLED,
        AVAILABLE_FOR_SALE
    }

    struct Product {
        uint256 productCode;
        string name;
        uint256 price;
        uint256 batchID;
        string expiryDate;
        string productDescription;
        uint256 quantity;
        uint256 availableQuantity;
        string productImage;
        ProductStatus status;
        address owner;  // Track owner of the product
        bool available;
    }

    mapping(uint256 => Product) public products;
    
    uint256[] public productList;

    event ProductSold(uint256 productCode, address buyer, uint256 quantity);
    event ProductStatusUpdated(uint256 productCode, ProductStatus newStatus);

    // Add new product
    function createPro(
        uint256 productCode,
        string memory name,
        uint256 price,
        uint256 batchID,
        string memory expiryDate,
        string memory productDescription,
        uint256 quantity,
        string memory productImage
    ) public {
        require(products[productCode].productCode == 0, "Product already exists");
        products[productCode] = Product(
            productCode,
            name,
            price,
            batchID,
            expiryDate,
            productDescription,
            quantity,
            quantity, // initially available quantity is total quantity
            productImage,
            ProductStatus.MANUFACTURED,
            msg.sender, // Manufacturer is the owner initially
            true
        );
        productList.push(productCode);
    }

        // Get product details
    function getProduct(uint256 productCode) public view returns (Product memory) {
        require(products[productCode].productCode != 0, "Product not found");
        return products[productCode];
    }

    // Check if product is available for sale
    function isProductAvailable(uint256 productCode) public view returns (bool) {
        return products[productCode].status == ProductStatus.AVAILABLE_FOR_SALE && products[productCode].availableQuantity > 0;
    }

    // Buy product function
    function buyProduct(uint256 productCode, uint256 quantity) public payable {
    
        require(products[productCode].productCode != 0, "Product not found");
        require(products[productCode].status == ProductStatus.AVAILABLE_FOR_SALE, "Product not available for sale");
        require(products[productCode].availableQuantity >= quantity, "Not enough stock available");
        
        uint256 totalPrice = products[productCode].price * quantity;
        require(msg.value >= totalPrice, "Insufficient payment");

        // Transfer ownership and reduce available quantity
        products[productCode].availableQuantity -= quantity;
        products[productCode].owner = msg.sender;

        emit ProductSold(productCode, msg.sender, quantity);
    }

    function getProductPrice(uint256 productId) public view returns (uint256) {
        require(products[productId].available, "Product is not available");
        
        return products[productId].price;
    }


    // Update product status
    function updateProductStatus(uint256 productCode, ProductStatus newStatus) public {
        Product storage product = products[productCode];
        
        require(product.productCode != 0, "Product not found");
        require(msg.sender == product.owner, "Only the owner can update product status"); 

        product.status = newStatus;
    
        emit ProductStatusUpdated(productCode, newStatus);
    }


    // Transfer product ownership (from manufacturer to retailer)
    function transferProduct(uint256 productCode, address newOwner) public {
        Product storage product = products[productCode];
        
        require(product.productCode != 0, "Product not found");
        require(msg.sender == product.owner, "Only the owner can transfer the product");
        
        product.owner = newOwner;
    }

    // Get all products
    function getAllProducts() public view returns (uint256[] memory) {
        return productList;
    }

    function getProductOwner(uint256 productCode) public view returns (address) {
        require(products[productCode].productCode != 0, "Product not found");
        return products[productCode].owner;
    }

    function markProductAsSold(uint256 productCode) public {
        Product storage product = products[productCode];
        
        require(product.productCode != 0, "Product not found");
        require(product.availableQuantity > 0, "No stock available");

        product.availableQuantity -= 1;  // Reduce available quantity by 1 
       
        if (product.availableQuantity == 0) {
            product.status = ProductStatus.SOLD_TO_CONSUMER; 
        }
    }

    function transferProductOwnership(uint256 productCode, address newOwner) public {
        Product storage product = products[productCode];
       
        require(product.productCode != 0, "Product not found");
        require(msg.sender == product.owner, "Only the owner can transfer the product");

        product.owner = newOwner;
    }

}
