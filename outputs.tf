// Includes output value definitions. 
output "public_ip_address" {
  value = azurerm_linux_virtual_machine.vm01.public_ip_address
}