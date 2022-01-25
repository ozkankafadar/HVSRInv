function output = Mutation(OldGen,Prob)
% OldGen : Old generation
% Prob   : Probability value
    rnd=rand(size(OldGen));
    mut =find(rnd<Prob);
    output = OldGen;
    output(mut) = 1-OldGen(mut);
end