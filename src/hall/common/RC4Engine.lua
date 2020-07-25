local RC4Engine = class("RC4Engine")

function RC4Engine:ctor(keybytes,keylen)
	self:UnInit();
end

function RC4Engine:UnInit()
	self.perm = {};
	for i = 0,255 do
		self.perm[i] = 0;
	end

	self.index1 = 0;

	self.index2 = 0;

	self.Initialized = false;

	self.count = 0;
end

function RC4Engine:SetInit(bInitialized)
	self.Initialized = bInitialized;
end

function RC4Engine:IsInit()
	return self.Initialized;
end

function RC4Engine:Setup(keybytes,keylen)
	self.perm = {};
	for i = 0,255 do
		self.perm[i] = 0;
	end
	local byteArray = {};
	for i = 0,keylen-1 do
		byteArray[i] = math.floor(keybytes/(math.pow(10,keylen-i-1)));
		keybytes = keybytes-byteArray[i]*math.pow(10,keylen-i-1);
		byteArray[i] = string.byte(tostring(byteArray[i]))
	end

	-- luaDump(byteArray,"byteArray");
	local i = 0;
	local j = 0;
	local k;
	self.count = 0;

	while i<256 do
		self.perm[i] = i;

		i = i+1;
	end

	i = 0;
	j = 0;
	-- luaDump(self.perm,"self.perm");
	while i<256 do
		j =j + self.perm[i] + byteArray[i % keylen];
		j=j % 256;
		k = self.perm[i]%256;
		self.perm[i] = self.perm[j];
		self.perm[j] = k;
		-- luaPrint("self.perm",i,j,self.perm[i],self.perm[j],byteArray[i % keylen])
		i = i+1;
	end
	self.Initialized = true;
	-- luaDump(self.perm,"self.perm")
end


function RC4Engine:Process(input,len)
	local output = {};

	if self.Initialized then
		self.count = self.count+1;
	end

	if not self.Initialized or input == nil then
		return nil;
	end

	local inputArray = {};
	for i=1,string.len(input) do
		table.insert(inputArray,string.byte(string.sub(input,i,i)))
	end

	local i = 0;
	local j,k;
	-- luaDump(inputArray,"inputArray")

	while i<len do
		self.index1 = self.index1+1;
		self.index1 = self.index1%256;
		self.index2 = self.index2 + self.perm[self.index1];
		self.index2 = self.index2%256;
		k = self.perm[self.index1]%256;
		self.perm[self.index1] = self.perm[self.index2];
		self.perm[self.index2] = k;

		j = self.perm[self.index1]+self.perm[self.index2];
		j = j % 256;

		output[i+1] = bit:_xor(inputArray[i+1],self.perm[j]);
		output[i+1] = output[i+1]%256;
		-- luaPrint("len",i,j,k,output[i+1],self.index1,inputArray[i+1])

		i = i+1;
	end

	-- luaDump(output,"output")
	local outputStr = "";
	for i = 1,#output do
		local str = tostring(output[i]);
		if string.len(str) == 2 then
			str = "0"..str;
		elseif string.len(str) == 1 then
			str = "00"..str;
		end

		outputStr = outputStr..str;
	end

	return outputStr;
end

function RC4Engine:GetPerm()
	return self.count;
end

return RC4Engine;