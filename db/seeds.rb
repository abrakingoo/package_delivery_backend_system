drivers_data = [
  { name: "James Mwangi",   email: "james@driver.com",   phone: "0712345601", latitude: -1.2921, longitude: 36.8219 }, # CBD
  { name: "Grace Wanjiru",  email: "grace@driver.com",   phone: "0712345602", latitude: -1.2833, longitude: 36.8167 }, # Westlands
  { name: "Brian Otieno",   email: "brian@driver.com",   phone: "0712345603", latitude: -1.3031, longitude: 36.8083 }, # Kibera
  { name: "Faith Njeri",    email: "faith@driver.com",   phone: "0712345604", latitude: -1.2695, longitude: 36.8508 }, # Kasarani
  { name: "Kevin Kamau",    email: "kevin@driver.com",   phone: "0712345605", latitude: -1.3192, longitude: 36.8900 }, # Embakasi
  { name: "Mercy Achieng",  email: "mercy@driver.com",   phone: "0712345606", latitude: -1.2588, longitude: 36.7853 }, # Ruaka
  { name: "Peter Kariuki",  email: "peter@driver.com",   phone: "0712345607", latitude: -1.3321, longitude: 36.7167 }, # Rongai
  { name: "Diana Wairimu",  email: "diana@driver.com",   phone: "0712345608", latitude: -1.2406, longitude: 36.9069 }, # Thika Road
  { name: "Samuel Kiprop",  email: "samuel@driver.com",  phone: "0712345609", latitude: -1.2981, longitude: 36.7573 }, # Lavington
  { name: "Lydia Chebet",   email: "lydia@driver.com",   phone: "0712345610", latitude: -1.3067, longitude: 36.8353 }  # South B
]

drivers_data.each do |data|
  driver = Driver.find_or_create_by!(email: data[:email]) do |d|
    d.name                  = data[:name]
    d.phone                 = data[:phone]
    d.available             = true
    d.password              = "password123"
    d.password_confirmation = "password123"
  end

  DriverLocation.find_or_create_by!(driver: driver) do |loc|
    loc.latitude  = data[:latitude]
    loc.longitude = data[:longitude]
  end
end

puts "Seeded #{drivers_data.size} drivers around Nairobi"
