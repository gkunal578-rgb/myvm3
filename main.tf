resource "azurerm_resource_group" "love" {
  name     = "love1"
  location = "eastus"

}
resource "azurerm_virtual_network" "ram" {
  name                = "ram"
  location            = azurerm_resource_group.love.location
  resource_group_name = azurerm_resource_group.love.name
  address_space       = ["10.0.0.0/16"]

}
resource "azurerm_subnet" "sub1" {
  name                 = "sub"
  resource_group_name  = azurerm_resource_group.love.name
  virtual_network_name = azurerm_virtual_network.ram.name
  address_prefixes     = ["10.0.1.0/24"]

}
resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = azurerm_resource_group.love.location
  resource_group_name = azurerm_resource_group.love.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.sub1.id
    private_ip_address_allocation = "Dynamic"

  }
}
resource "azurerm_public_ip" "pip" {
  name                = "pip1"
  location            = azurerm_resource_group.love.location
  resource_group_name = azurerm_resource_group.love.name
  allocation_method   = "Static"

}
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg1"
  location            = azurerm_resource_group.love.location
  resource_group_name = azurerm_resource_group.love.name
  security_rule {
    name                       = "nsg2"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_windows_virtual_machine" "vm1" {
  name                  = "vm"
  location              = azurerm_resource_group.love.location
  resource_group_name   = azurerm_resource_group.love.name
  size                  = "Standard_D2s_v3"
  admin_username        = "adminuser"
  admin_password        = "Kunal@123"
  network_interface_ids = [azurerm_network_interface.nic.id]
  os_disk {

    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }
  source_image_reference {
    publisher = "microsoftwindowsserver"
    offer     = "windowsserver"
    sku       = "2016-Datacenter"
    version   = "latest"

  }
}
resource "azurerm_managed_disk" "disk1" {
  name                 = "disk2"
  location             = azurerm_resource_group.love.location
  resource_group_name  = azurerm_resource_group.love.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10

}
resource "azurerm_virtual_machine_data_disk_attachment" "datad" {
  managed_disk_id    = azurerm_managed_disk.disk1.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm1.id
  lun                = "10"
  caching            = "ReadWrite"
}
