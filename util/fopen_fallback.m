function fid = fopen_fallback(file,fallbackPth,permission,varargin)
% fid = fopen_fallback(file,fallbackPth,permission,varargin)

persistent lastSucc lastTime
if isempty(lastTime)
    lastTime = now;
end
if isempty(lastSucc)
    lastSucc = true;
end

fid = fopen(file,permission,varargin{:});
if fid < 0
    [~,n,e] = fileparts(file);
    if ~exist(fallbackPth,'dir'), mkdir(fallbackPth); end
    fid = fopen(fullfile(fallbackPth,[n e]),permission,varargin{:});
    if lastSucc || now-lastTime > 15/60/24
        fprintf('  --- Using fallback path (%s) ---\n', fallbackPth);
        lastTime = now;
    end
    lastSucc = false;
else
    lastSucc = true;
end
assert(fid>0,'Failed to open file \n\t%s\n and fallback \n\t(%s)', ...
    file, fallbackPth);

end