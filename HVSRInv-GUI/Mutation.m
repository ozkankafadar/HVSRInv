function output = Mutation(Old,P)
rnd=rand(size(Old));
mut =find(rnd<P);
output = Old;
output(mut) = 1-Old(mut);

