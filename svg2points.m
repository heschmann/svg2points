function path = svg2points(myStr,N)
% converts a svg path to a line segment using N points per segment

splitStr = split(myStr,' ');

curPoint = [0; 0];

path = [];
while ~isempty(splitStr)
    isRel = isstrprop(splitStr{1},'lower'); % relative
    charSel = splitStr{1}; % get char
    switch lower(charSel)
        case 'm'
            % move
            tmp = split(splitStr{2},',');
            curPoint = [str2double(tmp{1}); str2double(tmp{2})] + isRel*curPoint;
            splitStr = {splitStr{3:end}}';
        case 'c'
            % curve
            tmp = split(splitStr{2},',');
            CP1 = [str2double(tmp{1}); str2double(tmp{2})] + isRel*curPoint; % relative;

            tmp = split(splitStr{3},',');
            CP2 = [str2double(tmp{1}); str2double(tmp{2})] + isRel*curPoint; % relative;

            tmp = split(splitStr{4},',');
            nextPoint = [str2double(tmp{1}); str2double(tmp{2})] + isRel*curPoint; % relative

            C = [curPoint CP1 CP2 nextPoint];

            P = zeros(2,N);
            idx = 1;
            for i = linspace(0,1,size(P,2))
                P(:,idx) = bazier(i,C);
                idx = idx + 1;
            end
            curPoint = nextPoint;

            path = [path P];
            splitStr = {splitStr{5:end}}';
        case 'h'
            % horizontal
            nextPoint = [str2double(splitStr{2}); 0] + isRel*curPoint;

            path = [path curPoint+(nextPoint-curPoint).*linspace(0,1,N)];
            curPoint = nextPoint;
            splitStr = {splitStr{3:end}}';
        case 'v'
            % vertical
            nextPoint = [0; str2double(splitStr{2})] + isRel*curPoint;

            path = [path curPoint+(nextPoint-curPoint).*linspace(0,1,N)];
            curPoint = nextPoint;
            splitStr = {splitStr{3:end}}';
        case 'l'
            % line
            tmp = split(splitStr{2},',');
            nextPoint = [str2double(tmp{1}); str2double(tmp{2})] + isRel*curPoint;

            path = [path curPoint+(nextPoint-curPoint).*linspace(0,1,N)];
            curPoint = nextPoint;
            splitStr = {splitStr{3:end}}';

        case 'z'
            % close path using line
            nextPoint = path(:,1); % first point

            path = [path curPoint+(nextPoint-curPoint).*linspace(0,1,N)];
            curPoint = nextPoint;
            splitStr = {splitStr{2:end}}';
        case 'a'
            % arc
            tmp = split(splitStr{2},',');
            RX = str2double(tmp{1});
            RY = str2double(tmp{2});
            alpha = str2double(splitStr{3});
            largeArc = str2double(splitStr{4});
            sweepArc = str2double(splitStr{5});
            tmp = split(splitStr{6},',');

            nextPoint = [str2double(tmp{1}); str2double(tmp{2})] + isRel*curPoint; % relative

            syms cx cy
            Salpha = [cosd(alpha) -sind(alpha); sind(alpha) cosd(alpha)]';

            eqns = [((Salpha*(curPoint-[cx; cy]))./[RX; RY]), ((Salpha*(nextPoint-[cx; cy]))./[RX; RY])].^2;
            eqns = sum(eqns,1);
            Sol = solve(eqns==[1, 1],[cx cy]);
            clear cx cy
            Sol = double([Sol.cx(1) Sol.cx(2); Sol.cy(1) Sol.cy(2)]);

            diffStart = Salpha*(curPoint - Sol);
            diffEnd = Salpha*(nextPoint - Sol);
            ArcStart = 180/pi*atan2(diffStart(2,:)./RY, diffStart(1,:)./RX);
            ArcEnd = 180/pi*atan2(diffEnd(2,:)./RY, diffEnd(1,:)./RX);

            % fix direction from start to end
            for Nsol = 1:2
                if sweepArc
                    % should be increasing
                    if ArcStart(Nsol)>ArcEnd(Nsol)
                        ArcEnd(Nsol) = ArcEnd(Nsol) + 360;
                    end
                else
                    % should be decreasing
                    if ArcStart(Nsol)<ArcEnd(Nsol)
                        ArcEnd(Nsol) = ArcEnd(Nsol) - 360;
                    end
                end
            end

            % fix small or big arc
            SolIdx = find((abs(ArcStart-ArcEnd)>180==largeArc));
            Sol = Sol(:,SolIdx);
            ArcStart = ArcStart(SolIdx);
            ArcEnd = ArcEnd(SolIdx);

            p = linspace(ArcStart,ArcEnd,N);
            Arc = Salpha'*[RX*cosd(p); RY*sind(p)]+Sol;
            path = [path curPoint Arc nextPoint];
            curPoint = nextPoint;
            splitStr = {splitStr{7:end}}';
        otherwise
            % error
            disp(splitStr{1})
            error('this is not yet implemented.')
            % to do S (symmetrical)
            % to do Q (quadratic, control points are the same for both ends)
            % to do T (quadratic, symmetric)
            %
            % see https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths
    end
    % incremental
    if ~isempty(splitStr) && length(splitStr{1}) ~= 1
        % If a moveto is followed by multiple pairs of coordinates, the
        % subsequent pairs are treated as implicit lineto commands. (https://www.w3.org/TR/SVG/paths.html)
        % This may cause problems when plotting the path! always close
        % paths to be sure
        if lower(charSel) == 'm'
            if isRel
                charSel = 'l';
            else
                charSel = 'L';
            end
        end
        splitStr = {charSel splitStr{1:end}}'; % do another
    end
end
end

%% HELPERS
function B = bazier( t, P )
B = [0, 0]';

n = size(P, 2);
for i = 1:n
    B = B + b(t, i - 1, n - 1) * P(:, i);
end
end

function value = b(t, i, n)
value = nchoosek(n, i) * t^i * (1 - t)^(n - i);
end
