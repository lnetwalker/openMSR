program browsetest;
uses browse;

var kp : doc_pointer;

begin
        new(kp);
        writeln('Created Pointer, adding strings');
        AppendStringToList('Listen ',kp);
        AppendStringToList('können ',kp);
        AppendStringToList('nerven ',kp);
        AppendStringToList('oder   ',kp);
        AppendStringToList('helfen ',kp);

        browsetext(kp,1,1,70,20);
end.

