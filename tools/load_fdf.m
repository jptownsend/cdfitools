function [IM,NP,NV] = load_fdf(name,sliceno,imno)
%----------------------------------------
%function load_fdf
%Reads magnitude images in fdf format
%Assumes, that the last entry in header is checksum
%----------------------------------------
%Usage [IM,np,nv] = load_fdf(name,sliceno,imno);
%
%Input:
%name = name of data directory without the .dat or .img extension
%sliceno = slice number to read
%imno = image number to read; optional

%
%Output:
%IM = images, sorted by row
%np = number of points in each FID   (rows in IM); optional
%nv = number of phase encoding lines (columns in each image); optional
%
%Examples:
%[IM] = load_fdf('Test_data',1,1);
%[IM np nv] = load_fdf('Test_data,',1,1);
%
%----------------------------------------
% Maj Hedehus, Varian, Inc., Oct 2001.
% edited Nov 2003 -- Lulu Edwards (changed program to read in new names of files
%----------------------------------------

% format input name
dirname = sprintf('%s.img',name);

if (exist(dirname,'dir') == 0)
    dirname = sprintf('%s.dat',name);
    if (exist(dirname,'dir') == 0)
        error('Cannot find data directory');
    end
end


if exist('imno') == 0
    imno = 1;
end

if exist('sliceno') == 0
    sliceno = 1;
end


%fullname = sprintf('%s%cimage%04d.fdf',dirname,'\',imno); %something funky with the backslash going on...

fullname = sprintf('%s%cslice%03dimage%03decho001.fdf',dirname,'/',sliceno, imno);
fid = fopen(fullname,'r','ieee-be');
if fid == -1
    str = sprintf('Can not open file %s',fullname);
    error(str);
end

checksum_str = fgets(fid);
while isempty(findstr('checksum',checksum_str))
    str = checksum_str;
    
    % Get matrix size
    if (~isempty(findstr(str,'matrix')))
        n = findstr(str,'{');
        V = sscanf(str(n+1:length(str)),'%d, %d');
        np = V(1); nv = V(2);
    end

    % Get binary data type
    if (~isempty(findstr(str,'storage')))
        clist = findstr(str,'"');
        dtype = sscanf(str(clist(1)+1:clist(2)-1),'%s');
    end
    if (~isempty(findstr(str,'bits')))
        n = findstr(str,'=');
        bits = sscanf(str(n+1:length(str)),'%d');
    end
    
    checksum_str = fgets(fid);
end

if (dtype(1:3) == 'flo')
    precision = sprintf('float%d',bits);
elseif (dtype(1:3) == 'int')
    precision = sprintf('int%d',bits);
end

% Skip past NULL character that separates header and data
v = fread(fid,1,'uchar');
while v ~= 0
    v = fread(fid,1,'uchar');
end


[IM ct] = fread(fid,[np nv],precision);
IM = IM';

fclose(fid);

%imagesc(abs(IM));colormap gray; axis image; 


if nargout > 1
    NP = np;
end
if nargout > 2
    NV = nv;
end




