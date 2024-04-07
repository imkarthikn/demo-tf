# resource "aws_key_pair" "my_key_pair" {
#   # Replace with your actual public key in PEM format
#   public_key = <<EOF
# ssh-rsa AAAAB3NzaC1YCjEAAAABIwAAAQEAaquP/1+2sXmU3bWUHPhvZuJfi3Kn
# hByanP1Q2XBwHnNHsOIl1+UcL6LIUyQbOeDq+YGcsiH7yPUlzZ2Yjt+PfinDbB
# NvhBn5NQXUn1CcJlMNg2OCmf9D1cjZItONBilmBy+IGCiFSrYGMuXawXWr6P
# mn/DBP9v4lzSUh4IKuENOQWvXkBcQzVJ81ExhLBmcn8v6+LbPMH5HvfiEqzC
# ZTwDQGYJFj+qoCuQQ== test@example.com
# EOF

#   # Optional: Specify a custom name for the key pair
#   # key_name = "my-custom-key-name"
# }

# # Output the public key fingerprint for reference (private key not accessible)

# output "public_key_fingerprint" {
#   value = aws_key_pair.my_key_pair.key_fingerprint
# }