$q = [uri]::EscapeDataString($args -join ' ')
Start-Process "https://eng.ms/search?q=$q&filter=%5B%7B%22name%22:%22contentId%22,%22operator%22:%22eq%22,%22value%22:%22310dd059-c877-4f12-816b-c7a2ef5be9c1%22%7D%5D"
