function output = Mutation(OldGeneration,Probability)
% Old : Old generation
% P   : Probability value
    rnd=rand(size(OldGeneration));
    mut =find(rnd<Probability);
    output = OldGeneration;
    output(mut) = 1-OldGeneration(mut);
end