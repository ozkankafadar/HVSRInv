function output = Mutation(Old,P)
% Old : Old generation
% P   : Probability value
    rnd=rand(size(Old));
    mut =find(rnd<P);
    output = Old;
    output(mut) = 1-Old(mut);
end