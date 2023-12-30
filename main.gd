extends Control

@onready var msg: TextEdit = $MarginContainer/HBoxContainer/VBoxContainer2/Message
@onready var sig: TextEdit = $MarginContainer/HBoxContainer/VBoxContainer2/Signature

const private_file = "private.rsa"
const public_file = "public.rsa"

var rsa = Crypto.new()
var privateKey: CryptoKey
var publicKey: CryptoKey

func _on_btn_generate_pressed() -> void:
	var cryptoKey := rsa.generate_rsa(2048)
	var err: Error
	err = cryptoKey.save(private_file)
	if err != 0:
		msg.text = "Failed to save private key file. Error %s" % err
		return
	
	err = cryptoKey.save(public_file, true)
	if err != 0:
		msg.text = "Failed to save public key file. Error %s" % err
		return
		
	msg.text = "Generated new keypair. You may now load either key."


func _on_btn_unload_pressed() -> void:
	privateKey = null
	publicKey = null
	msg.text = "Unloaded all keys"


func _on_btn_load_private_pressed() -> void:
	publicKey = null
	privateKey = CryptoKey.new()
	var err := privateKey.load(private_file)
	if err != null and err != 0:
		msg.text =  "Failed to load private key. Error %s. Try generating a new pair." % err
	else:
		msg.text = "Successfully loaded private key"

func _on_btn_load_public_pressed() -> void:
	privateKey = null
	publicKey = CryptoKey.new()
	var err := publicKey.load(public_file, true)
	if err != 0:
		msg.text = "Failed to load public key. Error %s. Try generating a new pair." % err
	else:
		msg.text = "Successfully loaded public key"


func _on_btn_sign_pressed() -> void:
	if privateKey == null:
		sig.text = "No private key loaded. Please generate and load private key before signing."
		return
	
	var digest := get_message_digest()
	var signature := rsa.sign(HashingContext.HASH_SHA256, digest, privateKey)
	sig.text = signature.hex_encode()


func get_message_digest() -> PackedByteArray:
	var clearText := msg.text
	if clearText.length() == 0 or clearText == null:
		push_error("No cleartext present!")
		return PackedByteArray()
	
	var bytes := clearText.to_ascii_buffer()
	
	var buffer := PackedByteArray()
	buffer.resize(1024)
	buffer.fill(0)
	
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	var partial := false
	for i in range(bytes.size()):
		buffer[i % 1024] = bytes[i]
		partial = true
		if i % 1024 == 0 and i != 0:
			partial = false
			ctx.update(buffer)
			buffer.fill(0)
	
	if partial:
		ctx.update(buffer)
	
	return ctx.finish()


func _on_btn_verify_pressed() -> void:
	if publicKey == null:
		sig.text = "No public key loaded. Please generate and load private key before signing. "
		return

	var clearText := msg.text
	var signature := sig.text
	
	if clearText.length() == 0 or signature.length() == 0:
		msg.text = "Please enter a message and its signature before attempting verification."
		return
		
	var digest := get_message_digest()
	var sigBytes := signature.hex_decode()
	
	var valid = rsa.verify(HashingContext.HASH_SHA256, digest, sigBytes, publicKey)
	if valid:
		sig.text = "Signature verified!"
	else:
		sig.text = "Signature not valid!"
	

func _on_btn_exit_pressed() -> void:
	get_tree().quit()
